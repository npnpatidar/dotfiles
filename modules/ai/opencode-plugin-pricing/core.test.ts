// Tests for pricing-core.ts. Run: node pricing-core.test.ts
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import { rank, renderTable } from "./core.ts"

const model = (id: string, inP: number, outP: number, cache: number, cap: number, img = false) => ({
  id,
  cost: { text: { input: { price: inP, cache: { read: cache } }, output: { price: outP } } },
  go: { monthly_usage: { go: cap } },
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
}

// --- zero tokens: no NaN, no division blowups ---
{
  const [row] = rank([model("m", 1, 2, 0.1, 10)], 0, 0, 0)
  assert.equal(row.dollars, 0)
  assert.equal(row.pct, 0)
}

// --- render: code-block friendly, aligned, sorted, comma separated ---
{
  const rows = rank([model("a-very-long-model-name-here-xx", 1, 2, 0, 10), model("b", 0.1, 0.2, 0, 60)], 2000, 2000, 500)
  const out = renderTable(rows, {
    rolling: { percent: 10 },
    weekly: { percent: 20 },
    monthly: { percent: 30, resetsAt: "2026-12-17T13:16:47.000Z" },
  }, 2000, 2000, 500)

  const lines = out.split("\n")
  assert.match(lines[0], /^REQUEST SHAPE +2000 in \/ 2000 cache-read \/ 500 out tokens/, "header line")
  assert.ok(lines.some((l) => l.startsWith(" # model"), "column header"))
  assert.ok(lines.includes("-".repeat(lines.find((l) => l.trimStart().startsWith("#"))!.length)), "rule matches width")

  const body = lines.filter((l) => /^\s*\d+\s+\S/.test(l))
  assert.equal(body.length, 2, "one line per model")
  assert.match(body[0], /^\s*1\s+b\s/, "cheapest first")
  assert.match(body[1], /a-very-long-model-name-here-xx/)
  assert.ok(!/[│┌┐]/.test(out), "no box-drawing characters")
  assert.ok(lines.every((l) => !l.endsWith("  ")), "no trailing double spaces")
  assert.ok(out.includes("pool now: rolling 10%  weekly 20%  monthly 30%  monthly resets 17 Dec 2026 18:46 IST"))
  assert.match(out, /70% pool left ≈ 140,000 requests of this shape on b/, "capacity line with commas")
}

// --- render: unparseable reset time is passed through verbatim ---
{
  const rows = rank([model("m", 1, 1, 0, 10)], 100, 0, 10)
  const out = renderTable(rows, { monthly: { percent: 5, resetsAt: "not-a-date" } }, 100, 0, 10)
  assert.ok(out.includes("monthly resets not-a-date"), "raw timestamp kept")
}

// --- render without usage: no footer, no crash ---
{
  const out = renderTable(rank([model("m", 1, 1, 0, 10)], 100, 0, 10), undefined, 100, 0, 10)
  assert.ok(!out.includes("pool now:"))
  assert.ok(out.includes("REQUEST SHAPE"))
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
