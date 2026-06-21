/**
 * Model router: switch model per-tool based on a config file.
 *
 * Reads ~/.pi/agent/model-router.json for a "routing" array:
 *   { "tools": ["bash", "read", ...], "model": { "provider": "...", "id": "..." } }
 *
 * When a configured tool is called, the extension saves the current model
 * and switches to the mapped model. On agent_end the original model is restored.
 *
 * If no config file exists, inline defaults are used (same routing).
 */

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

interface ModelRef {
	provider: string;
	id: string;
}

interface RoutingEntry {
	tools: string[];
	model: ModelRef;
}

interface RouterConfig {
	routing: RoutingEntry[];
}

// Inline defaults used when no config file exists
const DEFAULT_ROUTING: RoutingEntry[] = [
	{
		tools: ["bash", "read", "grep", "find", "ls", "exa_search"],
		model: { provider: "opencode", id: "deepseek-v4-flash-free" },
	},
];

/**
 * Load config from ~/.pi/agent/model-router.json.
 * Falls back to DEFAULT_ROUTING if file is missing or invalid.
 */
function loadConfig(): RoutingEntry[] {
	const configPath = join(getAgentDir(), "model-router.json");

	if (!existsSync(configPath)) return DEFAULT_ROUTING;

	try {
		const raw = readFileSync(configPath, "utf-8");
		const config = JSON.parse(raw) as RouterConfig;

		if (!Array.isArray(config.routing) || config.routing.length === 0) {
			console.warn("[model-router] config has no routing entries, using defaults");
			return DEFAULT_ROUTING;
		}

		return config.routing;
	} catch (err) {
		console.warn(`[model-router] failed to read config (${configPath}), using defaults:`, err);
		return DEFAULT_ROUTING;
	}
}

export default function (pi: ExtensionAPI) {
	// Build tool → model lookup from routing config
	const toolModelMap = new Map<string, ModelRef>();

	for (const entry of loadConfig()) {
		for (const tool of entry.tools) {
			// Later entries override earlier ones — last wins
			toolModelMap.set(tool, entry.model);
		}
	}

	// Original model saved before the first switch
	let originalModel: ModelRef | null = null;

	pi.on("tool_call", async (event, ctx) => {
		const target = toolModelMap.get(event.toolName);
		if (!target) return;

		const cheapModel = ctx.modelRegistry.find(target.provider, target.id);
		if (!cheapModel) {
			console.warn(`[model-router] model ${target.provider}/${target.id} not found`);
			return;
		}

		if (ctx.model?.id === cheapModel.id && ctx.model?.provider === target.provider) return;

		if (!originalModel && ctx.model) {
			originalModel = { provider: ctx.model.provider, id: ctx.model.id };
		}

		const ok = await pi.setModel(cheapModel);
		if (!ok) {
			console.warn(`[model-router] failed to switch to ${target.provider}/${target.id}`);
			originalModel = null;
			return;
		}

		ctx.ui.setStatus("model-router", `↘ ${target.provider}/${target.id}`);
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (!originalModel) {
			ctx.ui.setStatus("model-router", undefined);
			return;
		}

		const restored = ctx.modelRegistry.find(originalModel.provider, originalModel.id);
		if (restored) {
			await pi.setModel(restored);
		}
		originalModel = null;
		ctx.ui.setStatus("model-router", undefined);
	});
}
