# niri config

My personal [niri](https://github.com/YaLTeR/niri) (Wayland compositor) configuration, split into small modules and paired with a [Quickshell](../quickshell/README.md) bar. It has two looks, **glassmorphism** (default) and **neo-brutalism**, that can be switched on the fly.

## Related repositories

This config is designed to work with its Quickshell counterpart, but each part can be used on its own:

- **niri config (this repo):** https://github.com/Sembarang28/niri-glassmorphism.git
- **Quickshell config (bar, launcher, panels):** https://github.com/Sembarang28/quickshell-glassmorphism.git

If you only want the niri setup, you can use it without Quickshell: remove the `spawn-sh-at-startup` line in `conf/startup.kdl` and the Quickshell keybinds in `conf/binds.kdl`.

## Features

- Full-width scrolling columns: every window takes the whole monitor, new apps open as a column to the right on the same workspace.
- Translucent, blurred application windows in the glassmorphism theme.
- Theme switching without restarting niri: niri reloads its config and Quickshell is restarted with the matching theme.
- Quickshell launcher, settings panel, and Wi-Fi / Bluetooth / Sound popups bound to keys.
- Modular config: one file per concern.

## Layout

```
~/.config/niri/
├── config.kdl          # main file, only `include`s
├── conf/
│   ├── environment.kdl # Qt / Wayland environment variables
│   ├── input.kdl       # keyboard, touchpad, mouse
│   ├── output.kdl      # monitor mode, scale, position
│   ├── layout.kdl      # columns, gaps, presets
│   ├── animations.kdl  # scroll and workspace animation springs
│   ├── rules.kdl       # per-app window rules
│   ├── startup.kdl     # autostart + screenshot path
│   └── binds.kdl       # all keybindings
├── themes/
│   ├── glassmorphism.kdl   # translucent, blurred windows (default)
│   └── neobrutalism.kdl    # thick borders, hard shadows
├── theme.kdl           # generated: includes the active theme
├── theme               # generated: name of the active theme
├── scripts/
│   ├── start-shell.sh  # starts Quickshell with the active theme
│   ├── theme.sh        # switch theme (niri + Quickshell)
│   └── shellctl.sh     # open/close Quickshell panels from keybinds
└── assets/
    └── wallpaper.jpg   # wallpaper, drawn by Quickshell
```

## Requirements

- niri 26.04 or newer (uses `background-effect` for blur)
- [Quickshell](https://quickshell.org) 0.3 or newer, with the Wayland and Pipewire services
- `pipewire` / `wireplumber` (`wpctl`), `networkmanager` (`nmcli`), `bluez` (`bluetoothctl`)
- `power-profiles-daemon` (for the power profile buttons)
- `cava` for the audio visualizer
- `libqalculate` (`qalc`) and `wl-clipboard` (`wl-copy`) for the launcher calculator
- `firefox` for links and web searches from the launcher
- `ddcutil` for monitor brightness over DDC/CI (your user must be in the `i2c` group)
- `nvidia-smi` for GPU stats (optional)
- `wttr.in` access for the weather widget (optional)
- Fonts: [Quicksand](https://fonts.google.com/specimen/Quicksand)

## Install

```sh
# clone to your config directory
git clone <your-repo-url> ~/.config/niri

# make the helper scripts executable
chmod +x ~/.config/niri/scripts/*.sh
```

The Quickshell configuration lives in `~/.config/quickshell` and is required for the bar and panels. See its README.

## Usage

### Keybindings

| Key | Action |
| --- | --- |
| `Mod+T` | Open Ghostty |
| `Alt+Space` | Open the Spotlight-style launcher (apps, calculator, links, web search) |
| `Mod+D` | Open the Quickshell app launcher |
| `Mod+Shift+D` | Open fuzzel |
| `Mod+S` | Open the Quickshell settings panel |
| `Mod+Q` | Close window |
| `Mod+H` / `Mod+L` | Previous / next column (scroll) |
| `Mod+Shift+scroll` | Scroll columns |
| `Mod+1` … `Mod+9` | Focus workspace |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+Alt+G` | Switch to glassmorphism |
| `Mod+Alt+N` | Switch to neo-brutalism |
| `Mod+Alt+T` | Toggle theme |
| `Mod+Shift+E` | Quit niri |

Press `Mod+Shift+/` to see the full list from niri.

### Switching themes

```sh
~/.config/niri/scripts/theme.sh glassmorphism
~/.config/niri/scripts/theme.sh neobrutalism
~/.config/niri/scripts/theme.sh toggle
```

This rewrites `theme.kdl` and `theme`, which niri picks up automatically, then restarts Quickshell with the matching theme.

### Changing the default theme

The default is set in two places. Change both to the same name:

- `theme` (the file): the name of the theme to start with (`glassmorphism` or `neobrutalism`).
- `theme.kdl`: `include "themes/<name>.kdl"`.

Or simply run `theme.sh <name>` once; it writes both files.

### Editing keybindings or layout

Edit the matching file in `conf/`. niri reloads the config as soon as the file is saved. Validate before saving with:

```sh
niri validate -c ~/.config/niri/config.kdl
```

## Starting after SDDM login

niri ships a session file, so it appears in the SDDM session menu as **niri**. Select it at the login screen and enter your password.

After login, niri runs the line in `conf/startup.kdl`:

```kdl
spawn-sh-at-startup "$HOME/.config/niri/scripts/start-shell.sh"
```

That script reads the active theme from `~/.config/niri/theme`, stops any running Quickshell, and starts Quickshell with `qs -p ~/.config/quickshell/<theme> -d`. This means the bar, launcher, and panels come up automatically, with no extra service or systemd unit.

To verify after logging in:

```sh
pgrep -a qs          # one qs process, with the theme path
qs log               # should contain no errors
```

To use a different theme on the next login, change the default as described above.

## Notes

- Hibernate is available in the Quickshell settings panel, but it needs a swap file or partition that is at least as large as your RAM and a `resume=` kernel parameter. Without that, it does nothing useful.
- Blur is provided by niri's `background-effect`. Its radius is not configurable in niri 26.04; use the window opacity to control how much of it shows.
- Qt apps are configured through `QT_QPA_PLATFORMTHEME=qt6ct` (see `conf/environment.kdl`). Install `qt6ct` and a Kvantum theme, then log out and back in.
