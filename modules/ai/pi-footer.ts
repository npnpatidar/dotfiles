/**
 * Custom footer: mirrors the built-in footer but shows actual context tokens
 * (e.g. 48.2k/200k (24%)) instead of only the percentage (24.1%/200k).
 *
 * Layout (same as built-in):
 *   line 1: pwd (git branch) • session name
 *   line 2: ↑input ↓output Rcache Wcache CHrate% $cost tokens/window (percent%)   model • thinking
 *   line 3: extension statuses (if any)
 */

import { isAbsolute, relative, resolve, sep } from "node:path";
import type { AssistantMessage, Usage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

function formatCwdForFooter(cwd: string, home: string | undefined): string {
	if (!home) return cwd;
	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(home);
	const relativeToHome = relative(resolvedHome, resolvedCwd);
	const isInsideHome =
		relativeToHome === "" ||
		(relativeToHome !== ".." && !relativeToHome.startsWith(`..${sep}`) && !isAbsolute(relativeToHome));
	if (!isInsideHome) return cwd;
	return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

interface Totals {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	latestCacheHitRate?: number;
}

function addUsage(totals: Totals, usage: Usage): void {
	totals.input += usage.input;
	totals.output += usage.output;
	totals.cacheRead += usage.cacheRead;
	totals.cacheWrite += usage.cacheWrite;
	totals.cost += usage.cost.total;
	const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
	if (promptTokens > 0) {
		totals.latestCacheHitRate = (usage.cacheRead / promptTokens) * 100;
	}
}

// OmniRoute keepalive sentinel: the gateway sends `data: {"model":"omniroute"}`
// keepalives before the real routing completes. pi-ai's openai-completions
// does `responseModel ||= chunk.model`, so the first keepalive locks
// responseModel to "omniroute" and the real `nvidia/...` model is lost.
// Filter that sentinel at the fetch layer so pi-ai sees only the actual model.
let lastOmniActualModel: string | undefined;
let fetchPatched = false;
function patchOmniFetch() {
	if (fetchPatched || typeof globalThis.fetch !== "function") return;
	fetchPatched = true;
	const origFetch = globalThis.fetch.bind(globalThis);
	globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
		const res = await origFetch(input as any, init as any);
		try {
			if (!res.body || !res.ok) return res;
			const ct = res.headers.get("content-type") || "";
			const isStream = ct.includes("text/event-stream");
			if (!isStream) return res;
			// Only filter streams that actually contain the omniroute sentinel; peek by
			// transforming the stream and filtering keepalive chunks.
			const decoder = new TextDecoder();
			const encoder = new TextEncoder();
			let buffer = "";
			const transform = new TransformStream<Uint8Array, Uint8Array>({
				transform(chunk, controller) {
					buffer += decoder.decode(chunk, { stream: true });
					const parts = buffer.split("\n");
					buffer = parts.pop() ?? "";
					for (const line of parts) {
						if (line.startsWith("data: ") && line.includes('"model":"omniroute"')) {
							// Drop keepalive sentinel entirely
							continue;
						}
						// Capture actual model for fallback display
						if (line.startsWith("data: ")) {
							try {
								const payload = JSON.parse(line.slice(6));
								if (payload?.model && payload.model !== "omniroute") {
									lastOmniActualModel = payload.model;
								}
							} catch {}
						}
						controller.enqueue(encoder.encode(line + "\n"));
					}
				},
				flush(controller) {
					if (buffer) {
						// Don't emit trailing sentinel
						if (!(buffer.startsWith("data: ") && buffer.includes('"model":"omniroute"'))) {
							controller.enqueue(encoder.encode(buffer));
						}
					}
				},
			});
			return new Response(res.body.pipeThrough(transform), {
				status: res.status,
				statusText: res.statusText,
				headers: res.headers,
			});
		} catch {
			return res;
		}
	}) as typeof fetch;
}

export default function (pi: ExtensionAPI) {
	patchOmniFetch();

	// Also capture provider response header fallback (in case keepalive filtering
	// missed) and patch persisted messages where pi-ai locked to "omniroute".
	pi.on("after_provider_response", (event) => {
		const h = event.headers["x-omniroute-model"] ?? event.headers["x-omniroute-model".toLowerCase()];
		if (h && h !== "omniroute") lastOmniActualModel = h;
	});
	pi.on("message_end", (event) => {
		if (event.message.role !== "assistant") return;
		const msg = event.message as AssistantMessage;
		if (msg.provider === "omni" && msg.responseModel === "omniroute" && lastOmniActualModel) {
			return { message: { ...msg, responseModel: lastOmniActualModel } };
		}
		if (msg.provider === "omni" && !msg.responseModel && lastOmniActualModel && msg.model !== lastOmniActualModel) {
			return { message: { ...msg, responseModel: lastOmniActualModel } };
		}
	});

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					// Cumulative usage across all session entries (same as built-in footer)
					const totals: Totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
					let lastAssistant: AssistantMessage | undefined;
					for (const e of ctx.sessionManager.getEntries()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const msg = e.message as AssistantMessage;
							addUsage(totals, msg.usage);
							lastAssistant = msg;
						} else if (e.type === "message" && e.message.role === "toolResult" && e.message.usage) {
							addUsage(totals, e.message.usage);
						} else if ((e.type === "branch_summary" || e.type === "compaction") && e.usage) {
							addUsage(totals, e.usage);
						}
					}

					// Context usage: actual tokens + percent (the built-in footer only shows percent)
					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const tokens = contextUsage?.tokens ?? null;
					const percent = contextUsage?.percent ?? null;

					// Line 1: pwd (git branch) • session name
					let pwd = formatCwdForFooter(
						ctx.sessionManager.getCwd(),
						process.env.HOME || process.env.USERPROFILE,
					);
					const branch = footerData.getGitBranch();
					if (branch) pwd = `${pwd} (${branch})`;
					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) pwd = `${pwd} • ${sessionName}`;

					// Line 2: stats
					const statsParts: string[] = [];
					if (totals.input) statsParts.push(`↑${formatTokens(totals.input)}`);
					if (totals.output) statsParts.push(`↓${formatTokens(totals.output)}`);
					if (totals.cacheRead) statsParts.push(`R${formatTokens(totals.cacheRead)}`);
					if (totals.cacheWrite) statsParts.push(`W${formatTokens(totals.cacheWrite)}`);
					if ((totals.cacheRead > 0 || totals.cacheWrite > 0) && totals.latestCacheHitRate !== undefined) {
						statsParts.push(`CH${totals.latestCacheHitRate.toFixed(1)}%`);
					}
					if (totals.cost) statsParts.push(`$${totals.cost.toFixed(3)}`);

					const windowStr = formatTokens(contextWindow);
					let contextStr: string;
					if (tokens === null) {
						contextStr = `?/${windowStr}`;
					} else if (percent === null) {
						contextStr = `${formatTokens(tokens)}/${windowStr}`;
					} else {
						contextStr = `${formatTokens(tokens)}/${windowStr} (${percent.toFixed(1)}%)`;
					}
					if (percent !== null && percent > 90) {
						statsParts.push(theme.fg("error", contextStr));
					} else if (percent !== null && percent > 70) {
						statsParts.push(theme.fg("warning", contextStr));
					} else {
						statsParts.push(contextStr);
					}

					const statsLeft = statsParts.join(" ");
					let statsLeftWidth = visibleWidth(statsLeft);
					if (statsLeftWidth > width) {
						// statsLeft itself too wide - truncate (drops colored context str edge cases)
						const truncated = truncateToWidth(statsLeft, width, "...");
						return [
							truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
							truncated,
						];
					}

					// Right side: model • thinking level, provider prefix if multiple providers
					// When the provider (e.g. omniroute) routes to a concrete backing model,
					// pi-ai surfaces it as `responseModel` (e.g. auto -> anthropic/claude-opus).
					// Show `requested → actual` so the user sees exactly which model served
					// the latest response. Falls back to plain model when no routing occurred.
					let modelName = ctx.model?.id || "no-model";
					// Prefer header/stream-captured actual model when pi-ai locked to sentinel "omniroute"
					let routed = lastAssistant?.responseModel;
					if (routed === "omniroute" && lastOmniActualModel) routed = lastOmniActualModel;
					if (!routed && lastOmniActualModel && lastAssistant?.provider === "omni") routed = lastOmniActualModel;
					const requested = lastAssistant?.model;
					const isRouted =
						!!routed &&
						!!requested &&
						routed !== requested &&
						routed !== "omniroute" &&
						!!ctx.model &&
						lastAssistant.provider === ctx.model.provider &&
						requested === ctx.model.id;
					if (isRouted) {
						modelName = `${requested} → ${routed}`;
					}
					let rightSideWithoutProvider = modelName;
					if (ctx.model?.reasoning) {
						const thinkingLevel = ctx.thinkingLevel || "off";
						rightSideWithoutProvider =
							thinkingLevel === "off" ? `${modelName} • thinking off` : `${modelName} • ${thinkingLevel}`;
					}
					let rightSide = rightSideWithoutProvider;
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						rightSide = `(${ctx.model.provider}) ${rightSideWithoutProvider}`;
						if (statsLeftWidth + 2 + visibleWidth(rightSide) > width) {
							rightSide = rightSideWithoutProvider;
						}
					}
					const rightSideWidth = visibleWidth(rightSide);
					let statsLine: string;
					if (statsLeftWidth + 2 + rightSideWidth <= width) {
						const padding = " ".repeat(width - statsLeftWidth - rightSideWidth);
						statsLine = statsLeft + padding + rightSide;
					} else {
						const availableForRight = width - statsLeftWidth - 2;
						if (availableForRight > 0) {
							const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
							const truncatedRightWidth = visibleWidth(truncatedRight);
							const padding = " ".repeat(Math.max(0, width - statsLeftWidth - truncatedRightWidth));
							statsLine = statsLeft + padding + truncatedRight;
						} else {
							statsLine = statsLeft;
						}
					}

					// Dim parts separately so inner color codes in statsLeft survive
					const dimStatsLeft = theme.fg("dim", statsLeft);
					const dimRemainder = theme.fg("dim", statsLine.slice(statsLeft.length));

					const pwdLine = truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "..."));
					const lines = [pwdLine, dimStatsLeft + dimRemainder];

					// Extension statuses (sorted, one line)
					const extensionStatuses = footerData.getExtensionStatuses();
					if (extensionStatuses.size > 0) {
						const sortedStatuses = Array.from(extensionStatuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, text]) => text);
						const statusLine = sortedStatuses.join(" ");
						lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
					}
					return lines;
				},
			};
		});
	});
}
