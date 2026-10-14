#!/bin/bash
set -Eeuo pipefail

# Register user-scoped MCP servers from claude/mcp.json.
#
# Claude Code stores MCP servers in ~/.claude.json, alongside account details,
# per-project history and assorted caches. That file is never symlinked into
# this repo. Instead the servers we care about are declared in claude/mcp.json
# (public) and optionally ~/.dotfiles-custom/claude/mcp.json (private), and
# registered through the CLI, which merges them into ~/.claude.json.

MCP_FILES=()
for candidate in "$HOME/.dotfiles/claude/mcp.json" "$HOME/.dotfiles-custom/claude/mcp.json"; do
  [[ -f "$candidate" ]] && MCP_FILES+=("$candidate")
done

if [[ ${#MCP_FILES[@]} -eq 0 ]]; then
  echo "No claude/mcp.json found, skipping MCP server registration"
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found, skipping MCP server registration"
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found, skipping MCP server registration"
  exit 0
fi

for MCP_FILE in "${MCP_FILES[@]}"; do
  for name in $(jq -r '.mcpServers | keys[]' "$MCP_FILE"); do
    if claude mcp get "$name" >/dev/null 2>&1; then
      echo "MCP server already registered: $name"
      continue
    fi

    echo "Registering MCP server: $name"
    claude mcp add-json --scope user "$name" "$(jq -c ".mcpServers[\"$name\"]" "$MCP_FILE")"
  done
done
