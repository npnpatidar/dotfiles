// Tests for pricing-core.ts. Run: node core.test.ts
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import { estimateSpend, istTime, rank, remainingRequests, renderLocalUsage, renderTable, timeUntil } from "./core.ts"

const model = (id: string, inP: number, outP: number, cache: number, cap: number, img = false) => ({
  id,
  name: id,
  cost: { text: { input: { price: inP, cache: { read: cache } }, output: { price: outP } } },
  go: { monthly_usage: { go: cap, "go-plus": cap * 2, "go-teams": cap + 5 } },
  limit: { context: 1_000_000 },
  modalities: { input: img ? ["text", "image/png"] : ["text"] },
})

// --- positive: ordering, math, and cache path ---
{
  const rows = rank(
    [
      model("expensive", 2, 10, 0.1, 15, true),
      model("cheap", 0.1, 0.2, 0.002, 60),
      model("mid", 0.15, 0.6, 0.003, 100, true),
    ],
    2000,
    2000,
    500,
  )
  assert.deepEqual(rows.map((r) => r.id), ["cheap", "mid", "expensive"], "ascending pool cost")
  // cheap: (0.1*2000 + 0.002*2000 + 0.2*500) / 1e6 = $0.000304
  assert.ok(Math.abs(rows[0].dollars - 0.000304) < 1e-12, "dollars formula incl. cache read")
  // 0.000304 / 60 * 100 = 0.0005066..%
  assert.ok(Math.abs(rows[0].pct - 0.0005066666666666667) < 1e-12, "pool percentage")
  assert.equal(rows[0].vis, false)
  assert.equal(rows[1].vis, true, "image modality detected")
}

// --- plan selection: caps differ per plan, so %pool and ranking change ---
{
  const rows = rank([model("a", 1, 2, 0, 10), model("b", 0.2, 0.4, 0, 60)], 2000, 0, 500, "go-teams")
  assert.equal(rows.find((r) => r.id === "a")!.cap, 15, "go-teams cap = go cap + 5")
  const plus = rank([model("a", 1, 2, 0, 10)], 2000, 0, 500, "go-plus")
  assert.equal(plus[0].cap, 20, "go-plus cap = 2x go cap")
}

// --- negative: models without a Go cap or without prices are skipped ---
{
  const rows = rank(
    [
      { id: "free", cost: { text: { input: { price: 0 }, output: { price: 0 } } }, go: { monthly_usage: null } },
      { id: "noprice", go: { monthly_usage: { go: 60 } } },
      model("ok", 0.1, 0.2, 0, 60),
    ],
    1000,
    0,
    100,
  )
  assert.deepEqual(rows.map((r) => r.id), ["ok"], "only priced, capped models survive")

  const chatOnly = rank([model("chat", 0.1, 0.2, 0, 60), { ...model("embedding", 0.01, 0, 0, 15), type: "embedding" }], 1000, 0, 100)
  assert.deepEqual(chatOnly.map((r) => r.id), ["chat"], "embedding models are omitted")
}

// --- zero tokens: no NaN, no division blowups ---
{
  const [row] = rank([model("m", 1, 2, 0.1, 10)], 0, 0, 0)
  assert.equal(row.dollars, 0)
  assert.equal(row.pct, 0)
}

// --- IST formatting and time remaining ---
{
  assert.equal(istTime("2026-12-17T13:16:47.000Z"), "17 Dec 18:46 IST", "UTC -> IST")
  assert.equal(istTime("not-a-date"), "not-a-date", "invalid input passed through")
  const now = new Date("2026-11-22T01:00:00.000Z")
  assert.equal(timeUntil("2026-11-22T06:12:00.000Z", now), "5h 12m")
  assert.equal(timeUntil("2026-11-30T00:00:00.000Z", now), "7d 23h")
  assert.equal(timeUntil("2026-11-22T00:00:00.000Z", now), "now")
}

// --- remaining requests: monthly pool already 30% used ---
{
  const [row] = rank([model("m", 1, 2, 0, 100)], 1000, 0, 100)
  // $0.0012/req, cap $100, 70% left = $70 -> 58,333 requests
  assert.equal(remainingRequests(row, { monthly: { percent: 30 } }), 58333)
  assert.equal(remainingRequests(row, undefined), null, "no usage -> unknown")
}

// --- render: usage meters in IST, aligned pricing table, plan label ---
{
  const rows = rank([model("a-very-long-model-name-here-xx", 1, 2, 0, 10), model("b", 0.1, 0.2, 0, 60)], 2000, 2000, 500)
  const now = new Date("2026-11-22T01:00:00.000Z")
  const out = renderTable(rows, {
    rolling: { percent: 10, status: "ok", resetsAt: "2026-11-22T06:00:00.000Z" },
    weekly: { percent: 20, status: "ok" },
    monthly: { percent: 30, status: "rate-limited", resetsAt: "2026-12-17T13:16:47.000Z" },
  }, 2000, 2000, 500, "go", now)

  const lines = out.split("\n")
  assert.match(lines[0], /^REQUEST SHAPE +2000 in \/ 2000 cache-read \/ 500 out tokens.*plan: Go/)
  assert.ok(lines.some((l) => l.startsWith(" # model")), "column header")
  assert.ok(lines.some((l) => l.includes("USAGE rolling (5h)") && l.includes("10%") && l.includes("5h 0m") && l.includes("22 Nov 11:30 IST")), "rolling meter")
  assert.ok(lines.some((l) => l.includes("USAGE monthly") && l.includes("rate-limited") && l.includes("17 Dec 18:46 IST")), "monthly meter + IST reset")
  assert.ok(lines.includes("-".repeat(lines.find((l) => l.trimStart().startsWith("#"))!.length)), "rule matches width")

  const body = lines.filter((l) => /^\s*\d+\s+\S/.test(l))
  assert.equal(body.length, 2, "one line per model")
  assert.match(body[0], /^\s*1\s+b\s/, "cheapest first")
  assert.match(body[1], /a-very-long-model-name-here-xx/)
  assert.ok(body[0].includes("140,000"), "req/left reflects 30% monthly usage on $60 cap")
  assert.ok(!/[│┌┐#]/.test(body[0].replace(/\[[#.]+\]/g, "")), "no box-drawing chars in table")
  assert.ok(lines.every((l) => !l.endsWith("  ")), "no trailing double spaces")
  assert.ok(out.includes("pool now: rolling 10%  weekly 20%  monthly 30%  monthly resets 17 Dec 18:46 IST"))
  assert.match(out, /70% pool left ≈ 140,000 requests of this shape on b/, "capacity line with commas")
  assert.ok(out.includes("* model has peak-hour price multipliers"))
}

// --- render without usage: no meters, no footer, no crash ---
{
  const out = renderTable(rank([model("m", 1, 1, 0, 10)], 100, 0, 10), undefined, 100, 0, 10)
  assert.ok(!out.includes("pool now:"))
  assert.ok(!out.includes("USAGE rolling"))
  assert.ok(out.includes("USAGE unavailable"))
}

// --- local usage: per-day tokens, per-model totals, estimated spend ---
{
  const models = [{ id: "hy4-flash-free", cost: { text: { input: { price: 0.15, cache: { read: 0.01 } }, output: { price: 0.5 } } } }]
  const rows = [
    { day: "2026-11-22", provider: "opencode-go", model: "hy4-flash-free", sessions: 2, input: 2_000_000, output: 100_000, reasoning: 0, cache_read: 1_000_000, cache_write: 0, cost: 0 },
    { day: "2026-11-23", provider: "opencode-go", model: "hy4-flash-free", sessions: 1, input: 1_000_000, output: 50_000, reasoning: 0, cache_read: 500_000, cache_write: 0, cost: 0 },
  ]
  // (2M*0.15 + 1M*0.01 + 100k*0.5)/1e6 = $0.36 for day 1
  assert.ok(Math.abs(estimateSpend(rows[0], models)! - 0.36) < 1e-9)
  assert.equal(estimateSpend({ ...rows[0], model: "unknown" }, models), null, "unknown model -> no estimate")
  const out = renderLocalUsage(rows, models, 7)
  assert.ok(out.includes("last 7 days"), "window in header")
  assert.ok(out.includes("22 Nov"), "day label")
  assert.ok(out.includes("go"), "provider tag")
  assert.ok(out.includes("$0.36"), "estimated spend row")
  assert.ok(out.includes("$0.54"), "per-model total across days")
  assert.ok(out.includes("TOTAL"), "totals section")
  assert.ok(out.includes("sessions are attributed to their start day"), "caveat")
  assert.ok(renderLocalUsage([], models, 7).includes("no local usage"), "empty state")
}

// --- empty input ---
{
  assert.deepEqual(rank([], 100, 0, 10), [])
}

console.log("pricing-core: all tests passed")

// --- drift guard: pricing.ts inlines core.ts because the plugin loader cannot
// resolve relative imports. Fail if the two copies diverge.
{
  const read = (f: string) => readFileSync(new URL(f, import.meta.url), "utf8")
  const core = read("./core.ts").trim()
  const match = read("./pricing.ts").match(
    /\/\/ ---8<--- BEGIN PRICING CORE \(mirror of core\.ts\)\n([\s\S]*?)\/\/ ---8<--- END PRICING CORE/,
  )
  assert.ok(match, "pricing.ts contains the PRICING CORE markers")
  assert.equal(match![1].trim(), core, "pricing.ts core block must mirror core.ts exactly")
}
