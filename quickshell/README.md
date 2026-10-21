# Mocha Shell (Quickshell)

Quickshell port of `mocha-shell.html`: Catppuccin Mocha, Quicksand + JetBrainsMono Nerd Font, paired with the niri theme `~/.config/niri/themes/mocha.kdl`.

```
shell.qml            entry: wallpaper, bar, overlay panels, toasts, OSD, dialogs, lock, windows, IPC
services/            Theme (tokens), Prefs (state.json), Sys (stats/niri/audio/weather), Net (nmcli), Notifs, SettingsData
components/          Icon (SVGs extracted from the HTML), T/M text, Sw, Slide, Li, PanelBox, Btn, WinFrame …
modules/             Bar, Overlay (+ panels/: ArchMenu, AppMenu, Stats, Notifications, Power, Brightness, Sound,
                     Bluetooth, Wifi, Quick, Calendar, Launcher), AboutWindow, SettingsWindow, ForceQuitWindow,
                     LockScreen, Dialogs, Osd, Toasts, Wallpaper
scripts/             stats.sh, specs.sh
assets/              icons/*.svg, unix.jpg (wallpaper from the HTML)
```

IPC: `qs -p ~/.config/quickshell ipc call panel toggle <launcher|settings|about|forcequit|lock|wifi|bluetooth|sound|quick|calendar|stats|power|brightness|notifications>`
and `ipc call osd <volumeUp|volumeDown|volumeMute|brightnessUp|brightnessDown>` (wired in niri `conf/binds.kdl`).

Optional: `events.txt` (lines `HH:MM – HH:MM|Title`) fills "Today" in the calendar panel. Night Light needs `wlsunset`.
