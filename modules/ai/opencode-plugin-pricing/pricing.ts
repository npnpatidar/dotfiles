// /pricing — Go usage meters, model token prices and local per-model daily usage.
// Usage:  /pricing                       -> 2000 in / 2000 cache-read / 500 out, plan go, 7 days
//         /pricing 5000/2000/1500 go-plus 14
// Data: Go API (/v1/models, /v1/usage) + local OpenCode session DB.
//
// NOTE: the plugin loader cannot resolve relative imports, so the pure logic
// from core.ts is inlined below. core.test.ts asserts both stay identical.
import { Plugin } from "@opencode/plugin"
import { execFileSync } from "node:child_process"

// ---8<--- BEGIN PRICING CORE (mirror of core.ts)
// Pure pricing logic for the /pricing command. No OpenCode imports so it can be
// unit-tested with `node core.test.ts`.

export interface Row {
  id: string
  name: string
  in: number
  out: number
  cache: number
  cap: number
  ctx: number
  vis: boolean
  peak: boolean
  dollars: number
  pct: number
}

export interface Meter {
  status?: string
  percent?: number
  resetsAt?: string
}

export interface Usage {
  rolling?: Meter
  weekly?: Meter
  monthly?: Meter
}

export type Plan = "go" | "go-plus" | "go-teams"

const M = 1_000_000
const PLAN_LABEL: Record<Plan, string> = {
  go: "Go",
  "go-plus": "Go Plus",
  "go-teams": "Go Teams",
}

/** Rank Go models by cost as a percentage of the chosen plan's monthly pool. */
export function rank(models: any[], inTok: number, cacheTok: number, outTok: number, plan: Plan = "go"): Row[] {
  const rows: Row[] = []
  for (const m of models ?? []) {
    if (m?.type && m.type !== "chat") continue // skip embedding/decision-only models
    const cap = m?.go?.monthly_usage?.[plan]
    const t = m?.cost?.text
    const inPrice = t?.input?.price
    const outPrice = t?.output?.price
    if (!cap || inPrice === undefined || outPrice === undefined) continue
    const cacheRead = t?.input?.cache?.read ?? 0
    const dollars = (inPrice * inTok + cacheRead * cacheTok + outPrice * outTok) / M
    rows.push({
      id: String(m.id),
      name: String(m.name ?? m.id),
      in: inPrice,
      out: outPrice,
      cache: cacheRead,
      cap,
      ctx: m?.limit?.context ?? 0,
      vis: (m?.modalities?.input ?? []).some((x: string) => x.startsWith("image/")),
      peak: Array.isArray(m?.cost?.multipliers) && m.cost.multipliers.length > 0,
      dollars,
      pct: (dollars / cap) * 100,
    })
  }
  return rows.sort((a, b) => a.pct - b.pct)
}

const commas = (n: number) => n.toLocaleString("en-US")
const perRequest = (n: number) => "$" + n.toFixed(5)
const percent = (n: number) => n.toFixed(5)

/** Format an ISO timestamp in Asia/Kolkata (IST). */
export function istTime(iso: string | undefined): string {
  if (!iso) return "-"
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return String(iso)
  const s = new Intl.DateTimeFormat("en-IN", {
    timeZone: "Asia/Kolkata",
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(d)
  return `${s.replace(",", "")} IST`
}

/** Human-readable time remaining until an ISO timestamp. */
export function timeUntil(iso: string | undefined, now: Date): string {
  if (!iso) return "-"
  const ms = new Date(iso).getTime() - now.getTime()
  if (!Number.isFinite(ms)) return "-"
  if (ms <= 0) return "now"
  const mins = Math.floor(ms / 60_000)
  const days = Math.floor(mins / 1440)
  const hours = Math.floor((mins % 1440) / 60)
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${mins % 60}m`
  return `${mins}m`
}

const meterBar = (pct: number) => {
  const filled = Math.max(0, Math.min(10, Math.round(pct / 10)))
  return `[${"#".repeat(filled)}${".".repeat(10 - filled)}]`
}

export interface LocalUsage {
  day: string
  provider: string
  model: string
  sessions: number
  input: number
  output: number
  reasoning: number
  cache_read: number
  cache_write: number
  cost: number
}

const compact = (n: number) => {
  if (n >= 1e9) return `${(n / 1e9).toFixed(1)}B`
  if (n >= 1e6) return `${(n / 1e6).toFixed(1)}M`
  if (n >= 1e3) return `${(n / 1e3).toFixed(0)}k`
  return String(n)
}

const PROVIDER_TAG: Record<string, string> = {
  "opencode-go": "go",
  opencode: "zen",
  nvidia: "nv",
}

/** Estimated USD spend from catalog token prices (Go reports cost 0 locally). */
export function estimateSpend(row: LocalUsage, models: any[]): number | null {
  const m = models.find((x) => x?.id === row.model || String(x?.id ?? "").endsWith(`/${row.model}`))
  const t = m?.cost?.text
  if (!t) return null
  const inp = t.input?.price
  const out = t.output?.price
  if (typeof inp !== "number" || typeof out !== "number") return null
  const cache = typeof t.input?.cache?.read === "number" ? t.input.cache.read : 0
  return (row.input * inp + row.cache_read * cache + row.output * out) / M
}

/** Render per-day, per-model local token usage with token-price estimates. */
export function renderLocalUsage(rows: LocalUsage[], models: any[], window: string | number): string {
  const out: string[] = []
  const label = typeof window === "number" ? `last ${window} days` : window
  out.push(`DAILY TOKEN USAGE (IST, ${label}; est$ = catalog token prices, Go pool actuals come from the meters above)`)
  if (!rows.length) {
    out.push("  no local usage in this window")
    return out.join("\n")
  }
  const cols = [
    ["day", 12, false], ["model", 30, false], ["prov", 5, false], ["sess", 6, true],
    ["in", 8, true], ["out", 8, true], ["cacheR", 8, true], ["est$", 9, true],
  ] as const
  const fmtLine = (cells: string[]) => cols.map(([_, w, right], i) => (right ? (cells[i] ?? "").padStart(w) : (cells[i] ?? "").padEnd(w))).join(" ").replace(/\s+$/, "")
  out.push(fmtLine(cols.map(([h]) => h)))
  out.push("-".repeat(fmtLine(cols.map(([h]) => h)).length))
  const totals = new Map<string, LocalUsage>()
  for (const r of rows) {
    const est = estimateSpend(r, models)
    const day = new Date(`${r.day}T00:00:00Z`).toLocaleDateString("en-IN", { timeZone: "UTC", day: "2-digit", month: "short" })
    out.push(fmtLine([
      day,
      r.model.length > 30 ? r.model.slice(0, 29) + "…" : r.model,
      PROVIDER_TAG[r.provider] ?? r.provider.slice(0, 5),
      String(r.sessions),
      compact(r.input), compact(r.output), compact(r.cache_read),
      est === null ? "-" : `$${est.toFixed(2)}`,
    ]))
    const t = totals.get(r.model) ?? { ...r, day: "", sessions: 0, input: 0, output: 0, cache_read: 0, cost: 0 }
    t.sessions += r.sessions; t.input += r.input; t.output += r.output; t.cache_read += r.cache_read; t.cost += r.cost
    totals.set(r.model, t)
  }
  for (const [model, t] of [...totals].sort((a, b) => b[1].input - a[1].input)) {
    const est = estimateSpend(t, models)
    out.push(fmtLine(["TOTAL", model.slice(0, 30), "", String(t.sessions), compact(t.input), compact(t.output), compact(t.cache_read), est === null ? "-" : `$${est.toFixed(2)}`]))
  }
  out.push("note: sessions are attributed to their start day (IST) and last recorded model")
  return out.join("\n")
}

/** Requests of this shape still affordable with the remaining monthly pool. */
export function remainingRequests(row: Row, usage: Usage | undefined): number | null {
  const used = usage?.monthly?.percent
  if (typeof used !== "number" || row.dollars <= 0) return null
  const left = Math.max(0, (100 - used) / 100) * row.cap
  return Math.floor(left / row.dollars)
}

interface Column {
  h: string
  w: number
  right: boolean
  v: (r: Row, i: number) => string
}

const COLUMNS: Column[] = [
  { h: "#", w: 2, right: true, v: (_r, i) => String(i + 1) },
  { h: "model", w: 28, right: false, v: (r) => r.id + (r.peak ? "*" : "") },
  { h: "in$/M", w: 7, right: true, v: (r) => r.in.toFixed(3) },
  { h: "out$/M", w: 8, right: true, v: (r) => r.out.toFixed(3) },
  { h: "cache$/M", w: 8, right: true, v: (r) => r.cache.toFixed(3) },
  { h: "cap$", w: 6, right: true, v: (r) => String(r.cap) },
  { h: "$/req", w: 9, right: true, v: (r) => perRequest(r.dollars) },
  { h: "%pool", w: 9, right: true, v: (r) => percent(r.pct) },
  { h: "req/100%", w: 9, right: true, v: (r) => commas(Math.floor(100 / r.pct)) },
  { h: "req/left", w: 9, right: true, v: (r) => commas(remainingRequests(r, undefined) ?? 0) },
  { h: "ctx", w: 6, right: true, v: (r) => (r.ctx ? `${Math.round(r.ctx / 1000)}k` : "-") },
  { h: "vis", w: 3, right: false, v: (r) => (r.vis ? "yes" : "no") },
]

const align = (s: string, w: number, right: boolean) => (right ? s.padStart(w) : s.padEnd(w))

function line(cells: string[]): string {
  return COLUMNS.map((c, i) => align(cells[i] ?? "", c.w, c.right))
    .join(" ")
    .replace(/\s+$/, "")
}

/** Render the detailed usage meters + ranked pricing table. */
export function renderTable(
  rows: Row[],
  usage: Usage | undefined,
  inTok: number,
  cacheTok: number,
  outTok: number,
  plan: Plan = "go",
  now: Date = new Date(),
): string {
  const out: string[] = []
  out.push(
    `REQUEST SHAPE   ${inTok} in / ${cacheTok} cache-read / ${outTok} out tokens   (USD per 1M tokens, plan: ${PLAN_LABEL[plan]})`,
  )
  out.push("")

  if (usage) {
    const meters: Array<[string, Meter | undefined]> = [
      ["rolling (5h)", usage.rolling],
      ["weekly", usage.weekly],
      ["monthly", usage.monthly],
    ]
    for (const [label, m] of meters) {
      const pct = typeof m?.percent === "number" ? m.percent : 0
      const status = m?.status ?? "?"
      const left = timeUntil(m?.resetsAt, now)
      out.push(
        `USAGE ${label.padEnd(13)} ${String(pct).padStart(3)}% ${meterBar(pct)} ${status.padEnd(12)} resets ${istTime(m?.resetsAt)} (in ${left})`,
      )
    }
  } else {
    out.push("USAGE unavailable — no Go key (run /connect to sign in)")
  }
  out.push("")

  const cols = COLUMNS.map((c) => c.h)
  const rule = "-".repeat(line(cols).length)
  out.push(line(cols))
  out.push(rule)
  rows.forEach((r, i) =>
    out.push(
      line(COLUMNS.map((c) => (c.h === "req/left" ? commas(remainingRequests(r, usage) ?? 0) : c.v(r, i)))),
    ),
  )
  out.push(rule)

  if (usage) {
    const { rolling, weekly, monthly } = usage
    const parts = [
      `rolling ${rolling?.percent ?? "?"}%`,
      `weekly ${weekly?.percent ?? "?"}%`,
      `monthly ${monthly?.percent ?? "?"}%`,
    ]
    if (monthly?.resetsAt) parts.push(`monthly resets ${istTime(monthly.resetsAt)}`)
    out.push(`pool now: ${parts.join("  ")}`)

    const cheapest = rows[0]
    if (cheapest) {
      const leftPct = typeof monthly?.percent === "number" ? Math.max(0, 100 - monthly.percent) : 100
      const n = remainingRequests(cheapest, usage)
      if (n !== null) {
        out.push(`${leftPct}% pool left ≈ ${commas(n)} requests of this shape on ${cheapest.id} (${percent(cheapest.pct)}% each)`)
      }
    }
  }
  out.push("* model has peak-hour price multipliers (up to 2x)")
  return out.join("\n")
}
// ---8<--- END PRICING CORE

const BASE = "https://opencode.ai/inference/go/v1"
const DEFAULT_PROFILE = "2000/2000/500"
const LOCAL_USAGE_SCRIPT = `${process.env.HOME}/.config/opencode/pricing-usage.py`

async function goGet(path: string, apiKey?: string): Promise<any> {
  const headers: Record<string, string> = { "User-Agent": "opencode-pricing/1.0" }
  if (apiKey) headers.Authorization = `Bearer ${apiKey}`
  const res = await fetch(`${BASE}/${path}`, { headers })
  if (!res.ok) throw new Error(`${path} -> HTTP ${res.status}`)
  return res.json()
}

export default Plugin.define({
  id: "naresh.pricing",
  async setup(ctx) {
    let apiKey: string | undefined
    try {
      const conn = await ctx.integration.connection.active("opencode")
      if (conn) {
        const cred = await ctx.integration.connection.resolve(conn)
        apiKey = (cred as any)?.apiKey ?? (cred as any)?.key
      }
    } catch {}

    await ctx.command.transform((editor) => {
      editor.add({
        name: "pricing",
        description: "Go usage, model prices and daily tokens (/pricing in/cache/out [plan] [days])",
        execute: async ({ sessionID, prompt, delivery }) => {
          const args = (prompt.text ?? "").trim().split(/\s+/).filter(Boolean)
          const profile = args[0] || DEFAULT_PROFILE
          const planArg = args[1]
          const plan = (planArg === "go-plus" || planArg === "go-teams" || planArg === "go" ? planArg : "go") as Plan
          const windowArg = args[2] ?? "month"
          const numericDays = Math.max(1, Math.min(30, parseInt(windowArg, 10) || 7))
          const usageArg = windowArg === "month" ? "month" : String(numericDays)
          const today = new Intl.DateTimeFormat("en-IN", { timeZone: "Asia/Kolkata", day: "numeric", month: "short" }).format(new Date())
          const windowLabel = windowArg === "month" ? `this month (1–${today})` : `last ${numericDays} days`
          const [inTok, cacheTok, outTok] = profile.split("/").map((n: string) => parseInt(n, 10) || 0)

          const models = (await goGet("models")).data ?? []
          let usage: any
          try {
            usage = (await goGet("usage", apiKey)).usage
          } catch {}

          let local: LocalUsage[] = []
          try {
            local = JSON.parse(execFileSync("python3", [LOCAL_USAGE_SCRIPT, usageArg], { encoding: "utf8", timeout: 20_000, maxBuffer: 10_000_000 }))
          } catch {}

          const rows = rank(models, inTok, cacheTok, outTok, plan)
          let table = rows.length
            ? renderTable(rows, usage, inTok, cacheTok, outTok, plan)
            : "No Go models with monthly caps found in the models response."
          table += "\n\n" + renderLocalUsage(local, models, windowLabel)

          await ctx.session.prompt({
            ...prompt,
            sessionID,
            delivery,
            text:
              "Reply with exactly one fenced code block (triple backticks) containing the text below, " +
              "byte-for-byte: keep every space, row order and column width. Add no summary, no commentary, " +
              "no blank line before or after, and nothing after the closing fence.\n\n" +
              table,
          })
        },
      })
    })
  },
})
