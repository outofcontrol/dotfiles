#!/bin/bash
set -Eeuo pipefail

# Pull live settings from this machine back into the dotfiles repos.
# Run after changing Zed extensions, the iTerm profile, or Claude MCP servers,
# then review and commit in ~/.dotfiles and ~/.dotfiles-custom.

DOTFILES="$HOME/.dotfiles"
CUSTOM="$HOME/.dotfiles-custom"

echo 'Zed: refresh auto_install_extensions from the installed extensions'
ZED_INSTALLED="$HOME/Library/Application Support/Zed/extensions/installed"
if [[ -d "$ZED_INSTALLED" ]]; then
  python3 - "$DOTFILES/config/zed/settings.json" "$ZED_INSTALLED" <<'PY'
import json, os, re, sys
settings_path, installed_dir = sys.argv[1], sys.argv[2]
names = sorted(d for d in os.listdir(installed_dir) if not d.startswith('.'))
block = json.dumps({n: True for n in names}, indent=4)
block = block.replace('\n', '\n  ')
text = open(settings_path).read()
pattern = re.compile(r'"auto_install_extensions":\s*\{[^}]*\}', re.S)
if pattern.search(text):
    text = pattern.sub('"auto_install_extensions": ' + block, text)
else:
    text = text.rstrip().rstrip('}') + ',\n  "auto_install_extensions": ' + block + '\n}\n'
open(settings_path, 'w').write(text)
print('  ' + ', '.join(names))
PY
else
  echo '  Zed extensions directory not found, skipping'
fi

echo 'iTerm2: re-export the OOC profile'
ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
if [[ -f "$ITERM_PLIST" ]]; then
  python3 - "$ITERM_PLIST" "$DOTFILES/config/iterm/OOC.json" <<'PY'
import json, plistlib, sys
plist, out = sys.argv[1], sys.argv[2]
profiles = plistlib.load(open(plist, 'rb')).get('New Bookmarks', [])
ooc = next((p for p in profiles if p.get('Name') == 'OOC'), None)
if ooc is None:
    print('  No OOC profile found, skipping'); sys.exit(0)
import os
home = os.path.expanduser('~')
def clean(o):
    if isinstance(o, bytes): return None
    if isinstance(o, dict): return {k: clean(v) for k, v in o.items() if clean(v) is not None}
    if isinstance(o, list): return [clean(v) for v in o]
    if isinstance(o, str) and home in o: return o.replace(home, '~')
    return o
json.dump({'Profiles': [clean(ooc)]}, open(out, 'w'), indent=2)
print('  exported')
PY
fi

echo 'Claude Code: refresh mcp.json from ~/.claude.json'
if [[ -d "$CUSTOM/claude" && -f "$HOME/.claude.json" ]]; then
  jq '{mcpServers: .mcpServers}' "$HOME/.claude.json" > "$CUSTOM/claude/mcp.json"
  jq -r '.mcpServers | keys[]' "$CUSTOM/claude/mcp.json" | sed 's/^/  /'
else
  echo '  ~/.dotfiles-custom/claude not found, skipping'
fi

echo 'Claude Code: adopt new skills, commands and agents created directly in ~/.claude'
if [[ -d "$CUSTOM/claude" ]]; then
  for kind in skills commands agents; do
    for entry in "$HOME/.claude/$kind"/*; do
      [[ -e "$entry" ]] || continue
      name=$(basename "$entry")
      [[ -L "$entry" ]] && continue          # already linked (ours or Homebrew's)
      [[ "$name" == "synced" ]] && continue  # managed by Claude itself
      mkdir -p "$CUSTOM/claude/$kind"
      if [[ -e "$CUSTOM/claude/$kind/$name" ]]; then
        echo "  $kind/$name exists in both places, resolve by hand"
        continue
      fi
      mv "$entry" "$CUSTOM/claude/$kind/$name"
      ln -s "$CUSTOM/claude/$kind/$name" "$entry"
      echo "  adopted $kind/$name"
    done
  done
fi

echo
echo 'Review and commit:'
for repo in "$DOTFILES" "$CUSTOM"; do
  if [[ -d "$repo/.git" ]]; then
    echo "--- $repo"
    git -C "$repo" status --short
  fi
done
