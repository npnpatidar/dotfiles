/**
 * herdr-subagents — managed sub-agents in herdr tabs.
 *
 * The main pi agent can spawn sub-agents via the `subagent` tool. Each
 * sub-agent runs its own `pi` instance in a dedicated, named herdr tab.
 *
 * Role model:
 *   - main agent  -> has `subagent` (spawn + wait), `subagent_abort`, `subagents_list`
 *   - sub-agent   -> has `subagent_report`, `subagent_note`, `subagents_list`
 *                    and NEVER has `subagent`/`subagent_abort` (cannot spawn or abort)
 *
 * A sub-agent is identified by the marker PI_SUBAGENT_ROLE_ACTIVE in its
 * appended system prompt (written by the spawner). It finds its own identity
 * via the HERDR_* environment variables that herdr injects into every pane.
 * Reports/collaboration go through a small file registry.
 */

import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const HOME = os.homedir();
const BASE = path.join(HOME, ".cache", "pi-subagents");
const REGISTRY_DIR = path.join(BASE, "registry");
const PROMPTS_DIR = path.join(BASE, "prompts");

const MARKER = "PI_SUBAGENT_ROLE_ACTIVE";
const SPAWN_TOOL = "subagent";
const SUB_TOOLS = ["subagent_report", "subagent_note"];
const MAIN_TOOLS = ["subagent_abort"];

const AGENT_START_TIMEOUT_MS = 120_000;
const DEFAULT_TIMEOUT_MIN = 20;
const MAX_TIMEOUT_MIN = 180;
const MAX_ACTIVE = 8;
// Working entries older than this that no longer have a live herdr agent are
// presumed dead (crash/herdr restart/kill) and get their slot reclaimed.
const REAP_AGE_MS = 10 * 60_000;
const POLL_INTERVAL_MS = 3_000;
const REPORT_CAP = 20_000;

// ---------------------------------------------------------------------------
// herdr CLI helpers
// ---------------------------------------------------------------------------

function runHerdr(
  args: string[],
  timeoutMs = 60_000,
): { ok: boolean; result?: unknown; error?: string } {
  let res = spawnSync("herdr", args, {
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: 16 * 1024 * 1024,
  });
  if (res.error && (res.error as NodeJS.ErrnoException).code === "ENOENT") {
    res = spawnSync(path.join(HOME, ".nix-profile", "bin", "herdr"), args, {
      encoding: "utf8",
      timeout: timeoutMs,
      maxBuffer: 16 * 1024 * 1024,
    });
  }
  if (res.error) return { ok: false, error: String(res.error) };
  if (res.status !== 0)
    return {
      ok: false,
      error: (res.stderr || "").trim() || `herdr exited ${res.status}`,
    };
  try {
    const data = JSON.parse(res.stdout);
    if (data.error) return { ok: false, error: JSON.stringify(data.error) };
    return { ok: true, result: data.result };
  } catch {
    return { ok: false, error: res.stdout.slice(0, 500) };
  }
}

// ---------------------------------------------------------------------------
// registry helpers
// ---------------------------------------------------------------------------

function nowIso(): string {
  return new Date().toISOString();
}

function entryPath(pane: string): string {
  return path.join(REGISTRY_DIR, `${pane}.json`);
}

function readEntry(pane: string): any | null {
  try {
    return JSON.parse(fs.readFileSync(entryPath(pane), "utf8"));
  } catch {
    return null;
  }
}

function ensureDir(dir: string): void {
  fs.mkdirSync(dir, { recursive: true });
  try {
    fs.chmodSync(dir, 0o700);
  } catch {
    /* ignore */
  }
}

function writeEntry(entry: Record<string, unknown>): void {
  ensureDir(REGISTRY_DIR);
  entry.updated_at = nowIso();
  const target = entryPath(String(entry.pane));
  const tmp = `${target}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(entry, null, 2) + "\n");
  fs.renameSync(tmp, target);
}

function listEntries(): any[] {
  ensureDir(REGISTRY_DIR);
  try {
    return fs
      .readdirSync(REGISTRY_DIR)
      .filter((f) => f.endsWith(".json"))
      .map((f) => {
        try {
          return JSON.parse(
            fs.readFileSync(path.join(REGISTRY_DIR, f), "utf8"),
          );
        } catch {
          return null;
        }
      })
      .filter(Boolean);
  } catch {
    return [];
  }
}

function activeSubCount(): number {
  return listEntries().filter((e) => e.status === "working").length;
}

function truncate(s: string | undefined, n: number): string {
  if (!s) return "";
  return s.length > n ? `${s.slice(0, n)}…` : s;
}

function sanitizeLabel(s: string): string {
  const cleaned = s
    .replace(/\s+/g, " ")
    .replace(/[^\w\- .+]/g, "-")
    .trim()
    .slice(0, 40);
  return cleaned || "subagent";
}

function currentPaneId(): string | undefined {
  return process.env.HERDR_PANE_ID;
}

function isSubAgent(
  eventSystemPrompt: string,
  appendedSystemPrompt: string | undefined,
): boolean {
  return Boolean(
    (appendedSystemPrompt && appendedSystemPrompt.includes(MARKER)) ||
    eventSystemPrompt.includes(MARKER),
  );
}

// ---------------------------------------------------------------------------
// sub-agent launch
// ---------------------------------------------------------------------------

function buildSubagentPrompt(opts: {
  pane: string;
  tab: string;
  workspace: string;
  parentPane: string;
  parentTab: string;
  cwd: string;
  task: string;
}): string {
  return `${MARKER}

# SUBAGENT ROLE — control instructions

You are a sub-agent spawned by the main pi agent (pane ${opts.parentPane}, tab ${opts.parentTab}). You are NOT a top-level agent: no agent reports to you, you have no authority to delegate, and you CANNOT spawn sub-agents.

- sub-agent id: ${opts.pane}
- your pane: ${opts.pane}  |  tab: ${opts.tab}  |  workspace: ${opts.workspace}
- working directory: ${opts.cwd}
- sub-agent registry: ${REGISTRY_DIR}  (one JSON file per sub-agent, named <pane>.json)

## Your single task
${opts.task}

## Rules (mandatory)
1. Complete exactly the single task above and verify the outcome with concrete evidence (commands run, exit codes, outputs, files created or changed) before reporting. Do not start unrelated work.
2. You CANNOT spawn your own sub-agents: the "subagent" tool is not available to you. Never run "herdr agent start" or launch another AI agent (pi, claude, codex, etc.). Delegation is the main agent's job.
3. You are aware of sibling sub-agents: each is an entry in ${REGISTRY_DIR}/<pane>.json (fields: pane, tab, workspace, task, status, notes, report). Use the subagents_list tool to see them, read their entries via bash when coordination helps, and write collaboration notes into your own entry with the subagent_note tool.
4. You may directly message a sibling sub-agent: herdr agent prompt <peer-pane> "message" — but fire it WITHOUT --wait, because herdr's wait errors once the peer self-terminates (agent_not_running/agent_not_found) even when the message was delivered. Confirm delivery instead by polling the peer's registry entry (${REGISTRY_DIR}/<peer-pane>.json) until its notes/report contain your message text or the ack you asked for. Never re-delegate your task to a peer.
5. When the task is complete: call the subagent_report tool with your report (what you did, evidence, results, issues). The tool records the report, marks your entry done, and closes your pane — that terminates your session. The main agent reads your report from the registry.
6. If the task cannot be completed: call subagent_report with the reason (failed=true). Do not loop forever — if you are blocked for more than 10 minutes or made 2 failed attempts, report the failure and stop.
7. Work inside ${opts.cwd}. Do not modify files outside the task scope without reporting that you did.
8. The registry entry is your only report channel to the main agent — keep the final report self-contained and evidence-based.`;
}

async function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function closeTab(tabId: string, pane?: string): void {
  if (pane) {
    try {
      fs.rmSync(path.join(PROMPTS_DIR, `${pane}.md`), { force: true });
    } catch {
      /* ignore */
    }
  }
  try {
    runHerdr(["tab", "close", tabId], 15_000);
  } catch {
    /* ignore */
  }
}

// Drop terminal-status registry entries older than 7 days so the cache stays tidy.
function pruneRegistry(): void {
  try {
    const now = Date.now();
    for (const f of fs.readdirSync(REGISTRY_DIR)) {
      if (!f.endsWith(".json")) continue;
      try {
        const e = JSON.parse(
          fs.readFileSync(path.join(REGISTRY_DIR, f), "utf8"),
        );
        const done =
          e.status === "done" ||
          e.status === "failed" ||
          e.status === "aborted";
        if (
          done &&
          now - new Date(e.created_at ?? 0).getTime() > 7 * 24 * 3600_000
        ) {
          fs.rmSync(path.join(REGISTRY_DIR, f), { force: true });
        }
      } catch {
        /* ignore */
      }
    }
    // Also drop orphan prompt files (no registry entry) — e.g. spawns that crashed
    // before the sub-agent could self-prune, or pre-fix leftovers.
    const panes = new Set(listEntries().map((e: any) => e.pane));
    for (const f of fs.readdirSync(PROMPTS_DIR)) {
      if (!f.endsWith(".md")) continue;
      if (!panes.has(f.replace(/\.md$/, ""))) {
        try {
          fs.rmSync(path.join(PROMPTS_DIR, f), { force: true });
        } catch {
          /* ignore */
        }
      }
    }
  } catch {
    /* ignore */
  }
}

function collectReport(entry: any): { status: string; report: string } {
  return {
    status: entry?.status ?? "unknown",
    report: truncate(String(entry?.report ?? ""), REPORT_CAP),
  };
}

// Panes that currently run a live herdr agent, from one `herdr agent list` call.
// Filters out agents herdr has marked done/unknown — herdr keeps those rows in
// the list long after the pi inside the pane has terminated, so treating their
// panes as "alive" would leak pool slots for sub-agents that died without
// reporting. Returns null when the query fails, so callers can skip reclaim.
function alivePaneSet(): Set<string> | null {
  const r = runHerdr(["agent", "list"], 15_000);
  if (!r.ok || !r.result) return null;
  try {
    const agents = ((r.result as any).agents ?? []) as Array<{
      pane_id: string;
      agent_status: string;
    }>;
    return new Set(
      agents
        .filter(
          (a) => a.agent_status !== "done" && a.agent_status !== "unknown",
        )
        .map((a) => a.pane_id),
    );
  } catch {
    return null;
  }
}

// Working entries whose pane no longer runs an agent and that have been quiet
// long enough that startup races can't explain it → presumed dead. Reclaims the
// MAX_ACTIVE slot (marks aborted) and closes the leftover pane/tab.
function reclaimDeadSlots(): number {
  const alive = alivePaneSet();
  if (!alive) return 0;
  let reclaimed = 0;
  for (const e of listEntries()) {
    if (e.status !== "working") continue;
    if (Date.now() - new Date(e.updated_at ?? 0).getTime() < REAP_AGE_MS)
      continue;
    if (alive.has(e.pane)) continue; // genuinely alive — keep the slot
    writeEntry({
      ...e,
      status: "aborted",
      report: "Presumed dead: no live agent for 10+ minutes — slot reclaimed.",
    });
    if (e.tab) closeTab(e.tab, e.pane);
    reclaimed++;
  }
  return reclaimed;
}

// ---------------------------------------------------------------------------
// extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  // --- main agent tool: spawn a sub-agent (and optionally wait for it) ---

  pi.registerTool({
    name: SPAWN_TOOL,
    label: "Subagent",
    description:
      "Spawn a sub-agent in a new named herdr tab running its own pi instance, wait for its single-task report, then clean up. Call multiple times (parallel tool calls) to create as many sub-agents as needed; use wait=false to fire-and-forget and collect later with subagents_list.",
    parameters: Type.Object({
      task: Type.String({
        description: "The single, verifiable task for the sub-agent.",
      }),
      name: Type.Optional(
        Type.String({
          description: "Tab label / sub-agent name (default: subagent-<n>).",
        }),
      ),
      cwd: Type.Optional(
        Type.String({
          description:
            "Working directory for the sub-agent (default: current).",
        }),
      ),
      workspace: Type.Optional(
        Type.String({
          description: "herdr workspace id (default: current workspace).",
        }),
      ),
      wait: Type.Optional(
        Type.Boolean({
          description: "Block until the sub-agent reports (default: true).",
        }),
      ),
      timeoutMinutes: Type.Optional(
        Type.Number({
          description: `Max wait in minutes (default: ${DEFAULT_TIMEOUT_MIN}).`,
        }),
      ),
    }),
    async execute(toolCallId, params: any, signal, onUpdate) {
      const update = (text: string) =>
        onUpdate?.({ content: [{ type: "text" as const, text }] });

      // --- guards (reclaim dead slots from crashed sub-agents first) ---
      reclaimDeadSlots();
      if (activeSubCount() >= MAX_ACTIVE) {
        return {
          content: [
            {
              type: "text",
              text: `${MAX_ACTIVE} sub-agents are already active (registry: ${REGISTRY_DIR}). Wait for some to finish or collect reports with subagents_list before spawning more.`,
            },
          ],
        };
      }
      const workspace = params.workspace ?? process.env.HERDR_WORKSPACE_ID;
      if (!workspace) {
        return {
          content: [
            {
              type: "text",
              text: "Cannot determine herdr workspace (HERDR_WORKSPACE_ID is unset). Run pi inside a herdr pane.",
            },
          ],
        };
      }
      const parentPane = currentPaneId() ?? "unknown";
      const parentTab = process.env.HERDR_TAB_ID ?? "unknown";
      const cwd = params.cwd ?? process.cwd();
      const name = params.name
        ? sanitizeLabel(params.name)
        : `subagent-${listEntries().length + 1}`;

      // --- create tab ---
      update(`Creating herdr tab "${name}"…`);
      const created = runHerdr([
        "tab",
        "create",
        "--workspace",
        workspace,
        "--label",
        name,
        "--cwd",
        cwd,
      ]);
      if (!created.ok || !created.result) {
        return {
          content: [
            {
              type: "text",
              text: `Failed to create tab: ${created.error ?? "unknown error"}`,
            },
          ],
        };
      }
      const tabId: string = (created.result as any).tab?.tab_id;
      const pane: string = (created.result as any).root_pane?.pane_id;
      if (!tabId || !pane) {
        return {
          content: [
            {
              type: "text",
              text: `Tab created but pane/tab ids missing: ${JSON.stringify(created.result)}`,
            },
          ],
        };
      }

      // --- registry entry + prompt file ---
      const entry: Record<string, unknown> = {
        pane,
        tab: tabId,
        workspace,
        cwd,
        task: params.task,
        status: "working",
        notes: "",
        report: "",
        parent_pane: parentPane,
        parent_tab: parentTab,
        created_at: nowIso(),
      };
      pruneRegistry();
      writeEntry(entry);
      fs.mkdirSync(PROMPTS_DIR, { recursive: true });
      try {
        fs.chmodSync(PROMPTS_DIR, 0o700);
      } catch {
        /* ignore */
      }
      const promptFile = path.join(PROMPTS_DIR, `${pane}.md`);
      fs.writeFileSync(
        promptFile,
        buildSubagentPrompt({
          pane,
          tab: tabId,
          workspace,
          parentPane,
          parentTab,
          cwd,
          task: params.task,
        }),
      );
      try {
        fs.chmodSync(promptFile, 0o600);
      } catch {
        /* ignore */
      }

      // --- start pi in the pane (unique agent name, retry on transient shell-busy races) ---
      update(`Starting pi agent in pane ${pane}…`);
      const labelSlug =
        (name || "task")
          .toLowerCase()
          .replace(/[^a-z0-9_-]+/g, "-")
          .replace(/^-+|-+$/g, "")
          .slice(0, 20) || "task";
      const paneSlug = pane.toLowerCase().replace(/[^a-z0-9_-]/g, "-");
      const agentName = `sa-${labelSlug}-${paneSlug}`.slice(0, 32);
      let started:
        | { ok: boolean; result?: unknown; error?: string }
        | undefined;
      for (let attempt = 1; attempt <= 3 && !started?.ok; attempt++) {
        if (attempt > 1) {
          const waitMs = 4_000 * attempt;
          update(
            `Pane shell not ready yet — retrying agent start in ${waitMs / 1000}s (attempt ${attempt}/3)…`,
          );
          await sleep(waitMs);
        }
        started = runHerdr(
          [
            "agent",
            "start",
            agentName,
            "--kind",
            "pi",
            "--pane",
            pane,
            "--timeout",
            String(AGENT_START_TIMEOUT_MS),
            "--",
            "pi",
            "--provider",
            "nvidia",
            "--model",
            "nvidia/nemotron-3-ultra-550b-a55b",
            "--append-system-prompt",
            promptFile,
          ],
          AGENT_START_TIMEOUT_MS + 15_000,
        );
      }
      if (!started?.ok) {
        writeEntry({
          ...entry,
          status: "failed",
          report: `Failed to start pi in pane ${pane}: ${started.error}`,
        });
        closeTab(tabId, pane);
        return {
          content: [
            {
              type: "text",
              text: `Failed to start sub-agent in pane ${pane}: ${started.error}`,
            },
          ],
          details: {
            pane,
            tab: tabId,
            status: "failed",
            registry: entryPath(pane),
          },
        };
      }

      // --- kick the sub-agent to begin its task ---
      const kick = runHerdr(
        [
          "agent",
          "prompt",
          pane,
          "Begin your single assigned task NOW. Follow the SUBAGENT ROLE control instructions in your system prompt exactly. When finished or impossible, call subagent_report.",
        ],
        30_000,
      );
      if (!kick.ok) {
        // Agent may still pick it up; note the failure so we can diagnose on timeout.
        const e = readEntry(pane);
        if (e) {
          e.notes =
            (e.notes ? e.notes + "\n" : "") +
            `[${nowIso()}] kick prompt failed: ${kick.error}`;
          writeEntry(e);
        }
        // Fast-fail: if no live agent is actually running in the pane now, the
        // pi never really came up — mark failed instead of silently waiting out
        // the full timeout (works for wait=true and wait=false alike).
        const alive = alivePaneSet();
        if (alive !== null && !alive.has(pane)) {
          writeEntry({
            ...(readEntry(pane) ?? entry),
            status: "failed",
            report: `Pi did not come up in pane ${pane} (kick failed: ${kick.error}).`,
          });
          closeTab(tabId, pane);
          return {
            content: [
              {
                type: "text",
                text: `Sub-agent failed to start in pane ${pane} (kick failed: ${kick.error}) — marked failed.`,
              },
            ],
            details: {
              pane,
              tab: tabId,
              status: "failed",
              registry: entryPath(pane),
            },
          };
        }
      } else {
        update(`Sub-agent ${pane} kicked and working…`);
      }

      if (params.wait === false) {
        return {
          content: [
            {
              type: "text",
              text: `Sub-agent launched in tab "${name}" — pane ${pane}, tab ${tabId}. It will write its report to ${entryPath(pane)}. Check with subagents_list.`,
            },
          ],
          details: {
            pane,
            tab: tabId,
            status: "working",
            registry: entryPath(pane),
          },
        };
      }

      // --- poll for completion ---
      const timeoutMin = Math.min(
        params.timeoutMinutes ?? DEFAULT_TIMEOUT_MIN,
        MAX_TIMEOUT_MIN,
      );
      const deadline = Date.now() + timeoutMin * 60_000;
      let lastSeen = "";

      while (Date.now() < deadline) {
        if (signal?.aborted) {
          writeEntry({
            ...(readEntry(pane) ?? entry),
            status: "aborted",
            report: "Aborted by caller before completion.",
          });
          closeTab(tabId, pane);
          return {
            content: [
              { type: "text", text: `Sub-agent ${pane} aborted by caller.` },
            ],
          };
        }
        await sleep(POLL_INTERVAL_MS);
        const e = readEntry(pane);
        if (e) {
          if (
            e.status === "done" ||
            e.status === "failed" ||
            e.status === "aborted"
          ) {
            const { status, report } = collectReport(e);
            const closed = { ...readEntry(pane), closed_at: nowIso() };
            writeEntry(closed);
            closeTab(tabId, pane);
            return {
              content: [
                {
                  type: "text",
                  text: `Sub-agent ${pane} (tab ${tabId}, "${name}") finished with status **${status}**.\n\nReport:\n${report}`,
                },
              ],
              details: {
                pane,
                tab: tabId,
                status,
                report,
                registry: entryPath(pane),
              },
            };
          }
          if (e.updated_at && e.updated_at !== lastSeen) {
            lastSeen = e.updated_at;
            update(
              `Sub-agent ${pane} (${name}): status ${e.status} — still working…`,
            );
          }
        }
      }

      // --- timeout ---
      const e = readEntry(pane);
      writeEntry({
        ...(e ?? entry),
        status: "aborted",
        report: `Timed out after ${timeoutMin} minutes without a report.`,
      });
      closeTab(tabId, pane);
      return {
        content: [
          {
            type: "text",
            text: `Sub-agent ${pane} (${name}) did not report within ${timeoutMin} minutes — marked aborted and pane closed. Inspect ${entryPath(pane)} and pane ${pane} scrollback for clues.`,
          },
        ],
        details: {
          pane,
          tab: tabId,
          status: "aborted",
          registry: entryPath(pane),
        },
      };
    },
  });

  // --- main agent tool: abort a stuck fire-and-forget sub-agent ---

  pi.registerTool({
    name: "subagent_abort",
    label: "Abort a sub-agent",
    description:
      "Main agent only: abort a running sub-agent (typically one spawned with wait=false that appears stuck). Marks its registry entry aborted, closes its herdr pane (terminating that pi session), and closes its tab. Get pane ids from subagents_list.",
    parameters: Type.Object({
      pane: Type.String({
        description:
          "Pane id of the sub-agent to abort (e.g. w9:pK), from subagents_list.",
      }),
      reason: Type.Optional(
        Type.String({
          description: "Optional reason recorded in the entry's report field.",
        }),
      ),
    }),
    async execute(toolCallId, params: any) {
      const entry = readEntry(params.pane);
      if (!entry) {
        return {
          content: [
            {
              type: "text",
              text: `No registry entry for pane ${params.pane} — nothing to abort.`,
            },
          ],
        };
      }
      if (entry.status !== "working") {
        return {
          content: [
            {
              type: "text",
              text: `Sub-agent ${params.pane} is already ${entry.status} — nothing to abort.`,
            },
          ],
        };
      }
      const reason = params.reason
        ? ` Aborted by main agent: ${params.reason}`
        : " Aborted by main agent.";
      writeEntry({
        ...entry,
        status: "aborted",
        report: `${truncate(entry.report ?? "", 500)}${reason}`,
      });
      // close the pane (kills that pi); the tab auto-closes with its last pane
      const closed = runHerdr(["pane", "close", params.pane], 15_000);
      if (entry.tab) closeTab(entry.tab, params.pane); // prunes prompt file; no-op if already gone
      return {
        content: [
          {
            type: "text",
            text: `Sub-agent ${params.pane} aborted (entry marked aborted, pane${closed.ok ? "" : ` (close failed: ${closed.error})`}/tab closed).`,
          },
        ],
        details: {
          pane: params.pane,
          status: "aborted",
          registry: entryPath(params.pane),
        },
      };
    },
  });

  // --- shared tool: list all sub-agents (registry) ---

  pi.registerTool({
    name: "subagents_list",
    label: "List sub-agents",
    description:
      "List every sub-agent in the registry (including finished/closed ones) with pane, tab, task, status, notes, and report summary. Main agent uses it to track spawned sub-agents; sub-agents use it to see and coordinate with their siblings.",
    parameters: Type.Object({}),
    async execute() {
      const entries = listEntries();
      if (entries.length === 0) {
        return {
          content: [
            { type: "text", text: "No sub-agents in the registry yet." },
          ],
        };
      }
      const alive = alivePaneSet(); // null → herdr query failed → don't guess
      const lines = entries
        .sort((a, b) => (a.created_at < b.created_at ? 1 : -1))
        .map((e, i) => {
          const quietMs = Date.now() - new Date(e.updated_at ?? 0).getTime();
          const dead =
            alive !== null &&
            e.status === "working" &&
            quietMs > 10 * 60_000 &&
            !alive.has(e.pane);
          const ageMin = Math.max(
            0,
            Math.round(
              (Date.now() - new Date(e.created_at ?? 0).getTime()) / 60_000,
            ),
          );
          return `${i + 1}. [${e.pane}] ${e.status}${dead ? " (dead — no agent)" : ""} — tab ${e.tab}, ${ageMin}m old, cwd ${e.cwd}\n   task: ${truncate(e.task, 120)}\n   report: ${truncate(e.report, 200)}\n   notes: ${truncate(e.notes, 200)}`;
        });
      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { entries },
      };
    },
  });

  // --- sub-agent tool: final report + self-termination ---

  pi.registerTool({
    name: "subagent_report",
    label: "Submit final report",
    description:
      "Sub-agent only: record your final report in the registry, mark your entry done (or failed), and close your own herdr pane (terminating this session). Call this exactly once, when your single task is complete or impossible.",
    parameters: Type.Object({
      report: Type.String({
        description: "Final report: what you did, evidence, results, issues.",
      }),
      failed: Type.Optional(
        Type.Boolean({
          description: "Set true when the task could not be completed.",
        }),
      ),
    }),
    async execute(toolCallId, params: any) {
      const pane = currentPaneId();
      if (!pane) {
        return {
          content: [
            {
              type: "text",
              text: "Cannot self-identify: HERDR_PANE_ID is unset (not running inside a herdr pane).",
            },
          ],
        };
      }
      const entry = readEntry(pane);
      if (!entry) {
        return {
          content: [
            {
              type: "text",
              text: `No registry entry for pane ${pane} (${entryPath(pane)}). Did you inherit the subagent prompt? Refusing to self-close an unmanaged pane.`,
            },
          ],
        };
      }
      if (entry.status === "done" || entry.status === "failed") {
        return {
          content: [
            {
              type: "text",
              text: `Report already recorded (status ${entry.status}). Refusing to overwrite the final report.`,
            },
          ],
        };
      }
      entry.status = params.failed ? "failed" : "done";
      entry.report = String(params.report ?? "");
      writeEntry(entry);
      // Prune our own prompt file — covers wait=false runs where the main side
      // never observes completion (its closeTab/prune never fires).
      try {
        fs.rmSync(path.join(PROMPTS_DIR, `${pane}.md`), { force: true });
      } catch {
        /* ignore */
      }
      // Best-effort self-close; deferred so this response can flush first.
      setTimeout(() => {
        try {
          runHerdr(["pane", "close", pane], 10_000);
        } catch {
          /* ignore */
        }
      }, 800);
      return {
        content: [
          {
            type: "text",
            text: `Report recorded (status ${entry.status}). This pane will close in a moment — session terminating.`,
          },
        ],
      };
    },
  });

  // --- sub-agent tool: collaboration notes ---

  pi.registerTool({
    name: "subagent_note",
    label: "Collaboration note",
    description:
      "Sub-agent only: append a timestamped collaboration note to your own registry entry so sibling sub-agents and the main agent can read it. Use for intermediate findings, coordination info, or handoffs.",
    parameters: Type.Object({
      note: Type.String({ description: "Note text to append." }),
    }),
    async execute(toolCallId, params: any) {
      const pane = currentPaneId();
      if (!pane)
        return {
          content: [
            {
              type: "text",
              text: "Cannot self-identify: HERDR_PANE_ID is unset.",
            },
          ],
        };
      const entry = readEntry(pane);
      if (!entry)
        return {
          content: [
            { type: "text", text: `No registry entry for pane ${pane}.` },
          ],
        };
      const stamp = `[${new Date().toISOString()}] ${pane}: ${params.note}`;
      entry.notes = entry.notes ? `${entry.notes}\n${stamp}` : stamp;
      writeEntry(entry);
      return { content: [{ type: "text", text: "Note recorded." }] };
    },
  });

  // --- role reconciliation: enforce tool sets + reinforce sub-agent identity ---

  const REINFORCEMENT = `\n\n## Sub-agent enforcement (extension)\nYou are PI_SUBAGENT_ROLE_ACTIVE: a sub-agent, not a top-level agent. The subagent tool is disabled for you — you cannot spawn sub-agents. Complete your single assigned task, then call subagent_report to submit your report and close your pane. Use subagent_note for collaboration notes and subagents_list to see sibling sub-agents.`;

  function reconcileRole(
    appended: string | undefined,
    systemPrompt: string,
  ): void {
    const isSub = isSubAgent(systemPrompt, appended);
    const active = pi.getActiveTools();
    if (isSub) {
      const remove = [SPAWN_TOOL, ...MAIN_TOOLS];
      if (remove.some((t) => active.includes(t)))
        pi.setActiveTools(active.filter((t) => !remove.includes(t)));
    } else {
      const hasSubTools = SUB_TOOLS.some((t) => active.includes(t));
      if (hasSubTools)
        pi.setActiveTools(active.filter((t) => !SUB_TOOLS.includes(t)));
    }
  }

  pi.on("session_start", (_event, ctx) => {
    const options = ctx.getSystemPromptOptions?.();
    reconcileRole(options?.appendSystemPrompt, ctx.getSystemPrompt?.() ?? "");
  });

  pi.on("before_agent_start", (event) => {
    const appended = event.systemPromptOptions?.appendSystemPrompt;
    reconcileRole(appended, event.systemPrompt);
    if (isSubAgent(event.systemPrompt, appended)) {
      return { systemPrompt: event.systemPrompt + REINFORCEMENT };
    }
  });
}
