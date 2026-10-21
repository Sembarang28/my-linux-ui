#!/usr/bin/env bash
# Usage: shellctl.sh toggle <launcher|settings|about|forcequit|lock|wifi|bluetooth|sound|quick|calendar|stats|power|brightness|notifications> | close
#        shellctl.sh osd <volumeUp|volumeDown|volumeMute|brightnessUp|brightnessDown>
target=panel
if [ "$1" = osd ]; then target=osd; shift; fi
exec qs -p "$HOME/.config/quickshell" ipc call "$target" "$@"
