# Review: pi-subagents extension

Reviewed `modules/ai/pi-subagents/index.ts` (single file, wired in via
`modules/ai/pi-coding-agent.nix`), cross-checked against the installed pi docs
(`extensions.md`) and the actual `herdr` CLI.

## Verdict

Solid, well-engineered extension. The role model (main spawns/wait/abort,
sub-agents report/note, no recursion) is clean, the lifecycle (registry +
atomic tmp-rename writes + prompt-file pruning + tab/pane cleanup) is robust,
and API usage checks out against docs and the real herdr CLI (`tab create`,
`agent start --kind pi --timeout ≤300s`, `agent prompt`, `pane close`). No
blocking bugs — but a few real gaps worth fixing.

## Issues

**1. Crash leaks pool slots permanently (High).** `MAX_ACTIVE` counts entries
with `status === "working"` (lines 115, 260), but `pruneRegistry()` only reaps
`done/failed/aborted` entries (≥7 days). A sub-agent that dies without
reporting (herdr restart, kill, reboot) stays `working` forever and silently
consumes one of the 8 slots — if enough crash, all spawns fail. There's
`subagent_abort` as a manual escape hatch, but data-driven recovery would
help: on spawns, reap `working` entries that look dead (e.g. `updated_at`
older than a threshold + not being polled by a live wait loop).

**2. Null-spread writes to `registry/undefined.json` (Medium).** Both failure
paths in the wait loop do `writeEntry({ ...readEntry(pane), status: "aborted", ... })`
(lines 379, 410) — if the entry is missing (deleted mid-run), `{...null}`
yields `{}`, so a garbage `undefined.json` is written and the real pane is
never marked aborted (leaking a pool slot, per #1). Fix: `readEntry(pane) ?? entry`.

**3. "stale?" flag mislabels every healthy long-running sub-agent (Medium).**
`updated_at` only moves on writes (report/note/abort), so a quiet 30-minute
`wait=true` sub-agent is flagged `(stale?)` in `subagents_list` (line 476), and
the wait loop's progress updates (line 401) go silent after the first poll. A
heartbeat would fix both: e.g. the main wait loop writing a `last_seen_alive`
field each poll (a separate field, so the `lastSeen` change-detection still
works), surfaced in `subagents_list`.

**4. Failed kick ⇒ silent 20-minute wait (Low-Medium).** If `herdr agent
prompt` (the "Begin your task NOW" kick) fails, the failure is only logged to
`notes` — a `wait=true` spawn then blocks the main agent for the full default
timeout with no early signal. Since you can't distinguish "never started" from
"working quietly" without heartbeats (#3), this ties into that. At minimum,
the stale-detection in `subagents_list` + a shorter grace-period fail-fast
after a failed kick would help.

**5. Minor/cosmetic.**
- `subagent-${listEntries().length + 1}` (line ~280) can collide under
  concurrent spawns (agentName is safe — includes pane slug — so impact is
  just duplicate tab labels).
- `subagent_report` marks `done` then self-closes 800 ms later; if `pane
  close` fails (e.g. herdr teardown race), a live sub-agent pi can call
  `subagent_report` again and overwrite the final report. Consider a
  `report only if status === "working"` idempotency guard.
- Cache dir (`~/.cache/pi-subagents/registry`, `prompts`) holds task
  text/reports including potentially sensitive content — fine on a
  single-user box, but worth a note given prompts are 0644-ish by default
  umask.
- Unused params (`toolCallId`, `onUpdate` in report/note tools) — cosmetic.

## Verified against docs/CLI

- `ExtensionAPI` import path, `registerTool` shape,
  `execute(toolCallId, params, signal, onUpdate, ctx)`,
  `{ content: [{type:"text"}] }` returns — all match `extensions.md`.
- `getActiveTools`/`setActiveTools` (docs line 1624+), `before_agent_start`
  `{ systemPrompt }` return + `systemPromptOptions.appendSystemPrompt`
  (docs 521–556) — used correctly; per-turn systemPrompt replacement means
  the REINFORCEMENT block won't accumulate across turns.
- herdr CLI flags/limits (`--timeout` max 300s vs 120s used; `agent prompt`
  without `--wait` as instructed for peer messaging) — all consistent.