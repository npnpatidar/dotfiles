// /pricing — rank Go models by cheapest pool cost for a given request shape.
// Usage:  /pricing              -> default 2000 in / 2000 cache-read / 500 out
//         /pricing 5000/2000/1500
// Data: public https://opencode.ai/inference/go/v1/models + /v1/usage
//
// NOTE: the plugin loader cannot resolve relative imports, so the pure logic
// from core.ts is inlined below. core.test.ts asserts both stay identical.
import { Plugin } from "@opencode/plugin"

// ---8<--- BEGIN PRICING CORE (mirror of core.ts)
// Pure pricing logic for the /pricing command. No OpenCode imports so it can be
// unit-tested with `node pricing-core.test.ts`.

export interface Row {
  id: string
  in: number
  out: number
  cache: number
  cap: number
  ctx: number
  vis: boolean
  dollars: number
  pct: number
}

export interface Usage {
  rolling?: { percent?: number; resetsAt?: string }
  weekly?: { percent?: number; resetsAt?: string }
  monthly?: { percent?: number; resetsAt?: string }
}

const M = 1_000_000

/** Rank Go models by cost as a percentage of the shared monthly pool. */
export function rank(models: any[], inTok: number, cacheTok: number, outTok: number): Row[] {
  const rows: Row[] = []
  for (const m of models ?? []) {
    const cap = m?.go?.monthly_usage?.go
    const t = m?.cost?.text
    const inPrice = t?.input?.price
    const outPrice = t?.output?.price
    if (!cap || inPrice === undefined || outPrice === undefined) continue
    const cacheRead = t?.input?.cache?.read ?? 0
    const dollars = (inPrice * inTok + cacheRead * cacheTok + outPrice * outTok) / M
    rows.push({
      id: String(m.id),
      in: inPrice,
      out: outPrice,
      cache: cacheRead,
      cap,
      ctx: m?.limit?.context ?? 0,
      vis: (m?.modalities?.input ?? []).some((x: string) => x.startsWith("image/")),
      dollars,
      pct: (dollars / cap) * 100,
    })
  }
  return rows.sort((a, b) => a.pct - b.pct)
}

const commas = (n: number) => n.toLocaleString("en-US")
const perRequest = (n: number) => "$" + n.toFixed(5)
const percent = (n: number) => n.toFixed(5)

interface Column {
  h: string
  w: number
  right: boolean
  v: (r: Row, i: number) => string
}

const COLUMNS: Column[] = [
  { h: "#", w: 2, right: true, v: (_r, i) => String(i + 1) },
  { h: "model", w: 30, right: false, v: (r) => r.id },
  { h: "in$/M", w: 7, right: true, v: (r) => r.in.toFixed(3) },
  { h: "out$/M", w: 8, right: true, v: (r) => r.out.toFixed(3) },
  { h: "cache$/M", w: 8, right: true, v: (r) => r.cache.toFixed(3) },
  { h: "cap$", w: 6, right: true, v: (r) => String(r.cap) },
  { h: "$/req", w: 9, right: true, v: (r) => perRequest(r.dollars) },
  { h: "%pool", w: 8, right: true, v: (r) => percent(r.pct) },
  { h: "reqs/100%", w: 11, right: true, v: (r) => commas(Math.floor(100 / r.pct)) },
  { h: "vis", w: 3, right: false, v: (r) => (r.vis ? "yes" : "no") },
]

const align = (s: string, w: number, right: boolean) => (right ? s.padStart(w) : s.padEnd(w))

function line(cells: string[]): string {
  return COLUMNS.map((c, i) => align(cells[i] ?? "", c.w, c.right))
    .join(" ")
    .replace(/\s+$/, "")
}

/** Render a fixed-width, code-block friendly table. */
export function renderTable(rows: Row[], usage: Usage | undefined, inTok: number, cacheTok: number, outTok: number): string {
  const head = COLUMNS.map((c) => c.h)
  const rule = "-".repeat(line(head).length)
  const out: string[] = []

  out.push(`REQUEST SHAPE   ${inTok} in / ${cacheTok} cache-read / ${outTok} out tokens   (USD per 1M tokens)`)
  out.push("")
  out.push(line(head))
  out.push(rule)
  rows.forEach((r, i) => out.push(line(COLUMNS.map((c) => c.v(r, i)))))
  out.push(rule)

  if (usage) {
    const { rolling, weekly, monthly } = usage
    const parts = [
      `rolling ${rolling?.percent ?? "?"}%`,
      `weekly ${weekly?.percent ?? "?"}%`,
      `monthly ${monthly?.percent ?? "?"}%`,
    ]
    if (monthly?.resetsAt) parts.push(`monthly resets ${monthly.resetsAt}`)
    out.push(`pool now: ${parts.join("  ")}`)

    const cheapest = rows[0]
    if (cheapest && typeof monthly?.percent === "number") {
      const left = Math.max(0, 100 - monthly.percent)
      const n = cheapest.pct > 0 ? Math.floor(left / cheapest.pct) : 0
      out.push(
        `${left}% pool left ≈ ${commas(n)} requests of this shape on ${cheapest.id} (${percent(cheapest.pct)}% each)`
      )
    }
  }
  return out.join("\n")
}
// ---8<--- END PRICING CORE

const BASE = "https://opencode.ai/inference/go/v1"
const DEFAULT_PROFILE = "2000/2000/500"

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
        description: "Go model prices as a code-block table (/pricing in/cache/out)",
        execute: async ({ sessionID, prompt, delivery }) => {
          const profile = (prompt.text ?? "").trim() || DEFAULT_PROFILE
          const [inTok, cacheTok, outTok] = profile.split("/").map((n: string) => parseInt(n, 10) || 0)

          const models = (await goGet("models")).data ?? []
          let usage: any
          try {
            usage = (await goGet("usage", apiKey)).usage
          } catch {}

          const rows = rank(models, inTok, cacheTok, outTok)
          const table = rows.length
            ? renderTable(rows, usage, inTok, cacheTok, outTok)
            : "No Go models with monthly caps found in the models response."

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
