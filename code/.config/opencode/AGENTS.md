# Agent Guidelines

This repository contains OpenCode configuration files.

## Commands
No build/lint/test commands detected in this repository.

## Code Style
- JSON formatting: Use 2 spaces for indentation
- Config structure: Follow OpenCode schema at https://opencode.ai/config.json
- Avoid sensitive info in config
- Keep config minimal and organized by section (mcp, permission, theme, agent)
- Agent configs should explicitly specify:
  - mode (primary/subagent)
  - model
  - tool permissions (write, edit, bash)
- Use descriptive agent names that indicate purpose and tier (e.g. build-pro, build-free)
- Remote MCP services must have type, url and enabled fields

## Maintainers
Project maintained via OpenCode. Configuration changes require appropriate permissions.