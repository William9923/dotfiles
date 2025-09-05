# OpenCode Configuration

Configuration for OpenCode AI assistant.

## MCP Servers

- **Semgrep**: Security and code analysis integration
  - Type: Remote
  - URL: https://mcp.semgrep.ai/mcp

- **Ref-tools**: Documentation search integration
  - Type: Remote
  - URL: https://api.ref.tools/mcp

## Permissions

- `edit`: Allowed without confirmation
- `bash`: Requires user confirmation
- `webfetch`: Allowed without confirmation

## Agents

### Code Reviewer
- Purpose: Reviews code for security, performance, and maintainability
- Model: github-copilot/gpt-5
- Disabled tools: write, edit
- Features: Integrates with Semgrep for security checks

### Planning Agents
1. **Plan Pro**
   - Model: github-copilot/gpt-5
   - Mode: Primary agent
   - Disabled tools: write, edit, bash
   
2. **Plan Free**
   - Model: github-copilot/gpt-4.1
   - Mode: Primary agent
   - Disabled tools: write, edit, bash

### Building Agents
1. **Build Pro**
   - Model: github-copilot/claude-sonnet-4
   - Mode: Primary agent
   - All tools enabled
   
2. **Build Free**
   - Model: github-copilot/claude-3.5-sonnet
   - Mode: Primary agent
   - All tools enabled

## Theme
System-based theme selection