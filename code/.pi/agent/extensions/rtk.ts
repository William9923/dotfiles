/**
 * RTK pi extension — rewrites bash commands via `rtk rewrite` for token savings.
 * Requires: rtk >= 0.23.0 in PATH.
 *
 * Toggle:
 * - /rtk [toggle|on|off|status]
 * - Ctrl+Alt+R
 */

import { execFileSync } from "node:child_process";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";

const STATUS_ID = "rtk";

function rtkAvailable(): boolean {
	try {
		execFileSync("which", ["rtk"], { stdio: "ignore" });
		return true;
	} catch {
		return false;
	}
}

function rewriteCommand(command: string): string {
	try {
		const rewritten = execFileSync("rtk", ["rewrite", command], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
		}).trim();
		return rewritten && rewritten !== command ? rewritten : command;
	} catch {
		return command;
	}
}

function updateStatus(ctx: ExtensionContext, enabled: boolean, available: boolean): void {
	if (!ctx.hasUI) return;
	if (!available) {
		ctx.ui.setStatus(STATUS_ID, ctx.ui.theme.fg("warning", "rtk: missing"));
		return;
	}
	ctx.ui.setStatus(
		STATUS_ID,
		enabled ? ctx.ui.theme.fg("accent", "rtk: on") : ctx.ui.theme.fg("warning", "rtk: off"),
	);
}

export default function (pi: ExtensionAPI) {
	const available = rtkAvailable();
	let enabled = true;

	pi.registerFlag("rtk-rewrite", {
		description: "Enable RTK bash rewrite extension",
		type: "boolean",
		default: true,
	});

	function setEnabled(next: boolean, ctx: ExtensionContext, notify = true): void {
		enabled = available && next;
		updateStatus(ctx, enabled, available);
		if (!notify) return;

		if (!available) {
			ctx.ui.notify("RTK binary not found; rewrite stays off.", "warning");
			return;
		}
		ctx.ui.notify(enabled ? "RTK rewrite enabled" : "RTK rewrite disabled", "info");
	}

	pi.registerCommand("rtk", {
		description: "Toggle RTK rewrite (/rtk [toggle|on|off|status])",
		handler: async (args, ctx) => {
			const action = (args ?? "toggle").trim().toLowerCase();
			if (action === "status") {
				updateStatus(ctx, enabled, available);
				ctx.ui.notify(
					available
						? `RTK rewrite is ${enabled ? "on" : "off"}`
						: "RTK binary not found; rewrite is off",
					"info",
				);
				return;
			}
			if (action === "on") return setEnabled(true, ctx);
			if (action === "off") return setEnabled(false, ctx);
			if (action === "toggle" || action === "") return setEnabled(!enabled, ctx);

			ctx.ui.notify("Usage: /rtk [toggle|on|off|status]", "warning");
		},
	});

	pi.registerShortcut(Key.ctrlAlt("r"), {
		description: "Toggle RTK rewrite",
		handler: async (ctx) => setEnabled(!enabled, ctx),
	});

	pi.on("session_start", async (_event, ctx) => {
		enabled = available && pi.getFlag("rtk-rewrite") !== false;
		updateStatus(ctx, enabled, available);
		if (!available) {
			console.warn("[rtk] rtk binary not found in PATH — rewrite disabled");
		}
	});

	pi.on("tool_call", async (event) => {
		if (!enabled || !available) return;
		if (!isToolCallEventType("bash", event)) return;

		const command = event.input.command;
		if (!command) return;

		const rewritten = rewriteCommand(command);
		if (rewritten !== command) {
			event.input.command = rewritten;
		}
	});
}
