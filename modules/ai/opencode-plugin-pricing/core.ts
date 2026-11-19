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
