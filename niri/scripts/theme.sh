#!/usr/bin/env bash
# Mocha is the only look now: re-applies themes/mocha.kdl and restarts Quickshell.
dir="$HOME/.config/niri"
echo mocha > "$dir/theme"
echo 'include "themes/mocha.kdl"' > "$dir/theme.kdl"
"$dir/scripts/start-shell.sh" >/dev/null 2>&1
