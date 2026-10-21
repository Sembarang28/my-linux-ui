#!/usr/bin/env bash
# Start the Quickshell config in ~/.config/quickshell (Mocha Shell)
pkill -x qs 2>/dev/null; sleep 0.3
exec qs -p "$HOME/.config/quickshell" -d
