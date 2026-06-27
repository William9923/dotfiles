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
 *
 * Runtime commands:
 *   /router-list
 *   /router-set <tool> <provider>/<model>
 *   /router-remove <tool>
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

interface RoutingEntry {
	tools: string[];
	model: ModelRef;
}

interface RouterConfig {
	routing: RoutingEntry[];
}

const DEFAULT_ROUTING: RoutingEntry[] = [
	{
		tools: ["bash", "read", "grep", "find", "ls", "exa_search"],
		model: { provider: "opencode-go", id: "deepseek-v4-flash" },
	},
];

function configPath(): string {
	return join(getAgentDir(), "model-router.json");
}

function loadConfig(): RoutingEntry[] {
	const path = configPath();
	if (!existsSync(path)) return DEFAULT_ROUTING;

	try {
		const raw = readFileSync(path, "utf-8");
		const config = JSON.parse(raw) as RouterConfig;
		if (!Array.isArray(config.routing) || config.routing.length === 0) {
			console.warn("[model-router] config has no routing entries, using defaults");
			return DEFAULT_ROUTING;
		}
		return config.routing;
	} catch (err) {
		console.warn(`[model-router] failed to read config (${path}), using defaults:`, err);
		return DEFAULT_ROUTING;
	}
}

function saveConfig(routing: RoutingEntry[]): void {
	const path = configPath();
	try {
		writeFileSync(path, JSON.stringify({ routing }, null, 2) + "\n", "utf-8");
	} catch (err) {
		console.warn(`[model-router] failed to write config (${path}):`, err);
		throw err;
	}
}

function routingToMap(routing: RoutingEntry[]): Map<string, ModelRef> {
	const map = new Map<string, ModelRef>();
	for (const entry of routing) {
		for (const tool of entry.tools) {
			map.set(tool, entry.model);
		}
	}
	return map;
}

function mapToRouting(map: Map<string, ModelRef>): RoutingEntry[] {
	const groups = new Map<string, string[]>();
	for (const [tool, model] of map) {
		const key = `${model.provider}/${model.id}`;
		const list = groups.get(key) ?? [];
		list.push(tool);
		groups.set(key, list);
	}
	return Array.from(groups, ([key, tools]) => {
		const [provider, ...idParts] = key.split("/");
		return { tools, model: { provider, id: idParts.join("/") } };
	});
}

export default function (pi: ExtensionAPI) {
	let routing = loadConfig();
	let toolModelMap = routingToMap(routing);
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

	pi.registerCommand("router-list", {
		description: "List current model-router tool mappings",
		handler: async (_args, ctx) => {
			if (toolModelMap.size === 0) {
				ctx.ui.notify("[model-router] no routes configured", "info");
				return;
			}
			const lines = mapToRouting(toolModelMap).map(
				(r) => `${r.model.provider}/${r.model.id}: ${r.tools.join(", ")}`,
			);
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});

	pi.registerCommand("router-set", {
		description: "Route a tool to a model: /router-set <tool> <provider>/<model>",
		handler: async (args, ctx) => {
			const [tool, modelRef] = args.trim().split(/\s+/);
			if (!tool || !modelRef) {
				ctx.ui.notify("Usage: /router-set <tool> <provider>/<model>", "error");
				return;
			}
			const [provider, ...idParts] = modelRef.split("/");
			if (!provider || idParts.length === 0) {
				ctx.ui.notify("Model must be provider/id", "error");
				return;
			}
			const model = ctx.modelRegistry.find(provider, idParts.join("/"));
			if (!model) {
				ctx.ui.notify(`Model not found: ${modelRef}`, "error");
				return;
			}
			toolModelMap.set(tool, { provider, id: idParts.join("/") });
			routing = mapToRouting(toolModelMap);
			saveConfig(routing);
			ctx.ui.notify(`[model-router] ${tool} → ${provider}/${idParts.join("/")}`, "info");
		},
	});

	pi.registerCommand("router-remove", {
		description: "Remove a tool route: /router-remove <tool>",
		handler: async (args, ctx) => {
			const tool = args.trim();
			if (!tool) {
				ctx.ui.notify("Usage: /router-remove <tool>", "error");
				return;
			}
			if (!toolModelMap.has(tool)) {
				ctx.ui.notify(`[model-router] ${tool} not routed`, "error");
				return;
			}
			toolModelMap.delete(tool);
			routing = mapToRouting(toolModelMap);
			saveConfig(routing);
			ctx.ui.notify(`[model-router] removed ${tool}`, "info");
		},
	});
}
