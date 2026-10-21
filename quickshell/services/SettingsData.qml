pragma Singleton
import Quickshell
import QtQuick

// Pane definitions of System Settings (same structure as NAV / PANES in mocha-shell.html).
// Row: { k: nav|toggle|value|select|range, ic, c, l, v, s, key, to }. Values starting with "@" are resolved live.
Singleton {
  function nav(ic, c, l, v, s, to) { return { k: "nav", ic: ic || "", c: c || "", l: l, v: v || "", s: s || "", to: to || "" } }
  function tog(ic, c, l, key, s) { return { k: "toggle", ic: ic || "", c: c || "", l: l, key: key, s: s || "" } }
  function val(ic, c, l, v, s) { return { k: "value", ic: ic || "", c: c || "", l: l, v: v || "", s: s || "" } }
  function sel(ic, c, l, v, s) { return { k: "select", ic: ic || "", c: c || "", l: l, v: v || "", s: s || "" } }
  function rng(ic, c, l, key) { return { k: "range", ic: ic, c: c, l: l, key: key } }

  readonly property var navGroups: [
    [["wifi", "Wi-Fi", "wifi", "blue"], ["bluetooth", "Bluetooth", "bluetooth", "blue"], ["network", "Network", "globe", "sapphire"], ["vpn", "VPN", "shield", "sapphire"], ["battery", "Battery", "battery", "green"]],
    [["general", "General", "gear", "overlay"], ["accessibility", "Accessibility", "access", "blue"], ["appearance", "Appearance", "contrast", "mauve"], ["control", "Control Center", "toggles", "overlay"], ["niri", "Desktop & niri", "columns", "lavender"], ["displays", "Displays", "sun", "sky"], ["screensaver", "Screen Saver", "image", "teal"], ["search", "Launcher", "search", "overlay"], ["wallpaper", "Wallpaper", "image", "teal"]],
    [["notifications", "Notifications", "bell", "red"], ["sound", "Sound", "volume", "pink"], ["focus", "Focus", "moon", "mauve"], ["screentime", "Screen Time", "hourglass", "lavender"]],
    [["lockscreen", "Lock Screen", "lock", "overlay"], ["privacy", "Privacy & Security", "hand", "blue"], ["users", "Users & Groups", "users", "blue"]],
    [["keyboard", "Keyboard", "keyboard", "overlay"], ["mouse", "Mouse", "mouse", "overlay"], ["printers", "Printers & Scanners", "printer", "overlay"]]
  ]
  function meta(id) { for (var g of navGroups) for (var n of g) if (n[0] === id) return { label: n[1], ic: n[2], c: n[3] }; return { label: id, ic: "gear", c: "overlay" } }

  readonly property var panes: ({
    wifi: { desc: "Connect to wireless networks with NetworkManager. Known networks join automatically.", groups: [
      [tog("wifi", "blue", "Wi-Fi", "wifi"), val("check", "green", "@wifiName", "Connected", "")],
      { title: "Known Networks", rows: [nav("wifi", "surface", "Kantor_Lt2", "Auto-join"), nav("wifi", "surface", "IndiHome-8F2A", "Auto-join"), nav("phone", "surface", "iPhone Agil", "Hotspot")] },
      [tog("", "", "Ask to join networks", "autojoin", "Known networks are joined automatically"), nav("", "", "Advanced…")]] },
    bluetooth: { desc: "Pair headphones, mice, keyboards and controllers through bluez.", groups: [
      [tog("bluetooth", "blue", "Bluetooth", "bt", "This PC is discoverable as “@host”")],
      { title: "My Devices", rows: [nav("headphones", "mauve", "WH-1000XM5", "Connected · 80%"), nav("mouse", "overlay", "MX Master 3S", "Connected · 64%"), nav("keyboard", "overlay", "Keychron K2", "Not Connected"), nav("gamepad", "overlay", "DualSense", "Not Connected")] }] },
    network: { desc: "Interfaces managed by NetworkManager, plus firewall and tunnels.", groups: [
      [nav("wifi", "blue", "Wi-Fi", "Connected", "wlan0"), nav("ethernet", "surface", "Ethernet", "Not Connected", "enp4s0 · Realtek 2.5GbE"), nav("shield", "sapphire", "Tailscale", "Connected", "100.84.12.7")],
      [tog("shield", "red", "Firewall", "firewall", "ufw · deny incoming"), nav("globe", "surface", "DNS", "1.1.1.1, 9.9.9.9")]] },
    vpn: { desc: "WireGuard and Tailscale tunnels.", groups: [
      [tog("shield", "sapphire", "wg0 (Home)", "wg", "WireGuard · 10.8.0.2"), tog("shield", "blue", "Tailscale", "ts", "archlinux.tail-mocha.ts.net")],
      [nav("plus", "surface", "Add VPN Configuration…")]] },
    battery: { desc: "This is a desktop PC, so no battery is present. Power behaviour is handled by power-profiles-daemon and hypridle.", groups: [
      [sel("gauge", "green", "Power Mode", "@profile"), val("zap", "yellow", "UPS", "Not detected")],
      [sel("monitor", "sky", "Turn display off after", "10 minutes"), sel("moon", "mauve", "Suspend after", "30 minutes")]] },
    general: { desc: "Manage your overall setup and preferences for this PC, such as package updates, language, autostart and more.", groups: [
      [nav("info", "overlay", "About", "", "", "about"), nav("download", "blue", "Software Update", "pacman", "pacman · paru"), nav("storage", "overlay", "Storage", "@disk")],
      [nav("rotate", "green", "Snapshots", "snapper", "btrfs @ and @home")],
      [nav("calendar", "blue", "Date & Time", "Asia/Jakarta"), nav("globe", "blue", "Language & Region", "en_US.UTF-8"), nav("list", "overlay", "Autostart", ""), nav("share", "overlay", "Sharing", "KDE Connect")],
      [nav("storage", "overlay", "Boot Loader", "Limine"), nav("restart", "overlay", "Transfer or Reset")]] },
    accessibility: { desc: "Adapt the desktop to your vision, hearing and motor needs.", groups: [
      { title: "Vision", rows: [tog("scan", "blue", "Zoom", "zoom", "Super + scroll"), nav("monitor", "blue", "Display"), nav("volume", "blue", "Spoken Content", "Orca")] },
      { title: "Motor", rows: [nav("keyboard", "overlay", "Keyboard"), nav("mouse", "overlay", "Pointer Control"), tog("sparkle", "mauve", "Reduce motion", "reduceMotion")] }] },
    appearance: { desc: "Catppuccin flavor, accent colour, fonts and icons used by GTK, Qt and Quickshell.", custom: "appearance" },
    control: { desc: "Choose which modules appear in the top bar. Order (left to right): stats, notifications, power mode, brightness, sound, Bluetooth, Wi-Fi, quick settings, clock.", groups: [
      { title: "Bar Modules", rows: [tog("cpu", "blue", "Stats", "showStats", "CPU, RAM, GPU usage and temperature"), tog("bell", "red", "Notifications", "showNotif"), tog("gauge", "mauve", "Power Mode", "showPower"), tog("sun", "yellow", "Brightness", "showBri"), tog("volume", "pink", "Sound", "showSound"), tog("bluetooth", "blue", "Bluetooth", "showBt"), tog("wifi", "blue", "Wi-Fi", "showWifi")] },
      { title: "Clock", rows: [sel("clock", "mauve", "Format", "Wednesday, Oct 21, 2026 14:32"), tog("", "", "Show seconds", "showSeconds")] }] },
    niri: { desc: "Scrollable tiling settings from ~/.config/niri/config.kdl.", groups: [
      [val("layers", "lavender", "Workspaces", "10"), val("columns", "lavender", "Gaps", "0 px"), val("scan", "mauve", "Focus ring", "off · floating 2 px accent"), sel("columns", "overlay", "Default column width", "100%")],
      [tog("", "", "Center focused column", "centerCol", "center-focused-column \"on-overflow\""), tog("", "", "Animations", "anims"), tog("", "", "Hot corner opens Overview", "hotcorner")]] },
    displays: { desc: "", custom: "displays" },
    screensaver: { desc: "Idle behaviour via hypridle and the Quickshell lock screen.", groups: [
      [sel("image", "teal", "Start after", "5 minutes"), sel("lock", "overlay", "Lock after", "10 minutes"), tog("", "", "Lock before sleep", "autoLock")]] },
    search: { desc: "Quickshell launcher (Super + D / Alt + Space): apps, links, calculator and web search.", groups: [
      [val("keyboard", "overlay", "Shortcut", "Alt Space"), tog("file", "blue", "Include files", "preview"), nav("list", "overlay", "Clipboard history", "cliphist")]] },
    wallpaper: { desc: "Simple dark wallpapers tuned for Catppuccin Mocha.", custom: "wallpaper" },
    notifications: { desc: "Quickshell notification daemon. Control previews and per-app alerts.", groups: [
      [sel("eye", "overlay", "Show previews", "Always"), tog("moon", "mauve", "Do Not Disturb", "dnd"), tog("volume", "pink", "Play sound", "notifSound")],
      { title: "Application Notifications", rows: [nav("users", "lavender", "Discord", "Banners"), nav("phone", "sky", "Telegram", "Banners"), nav("headphones", "green", "Spotify", "Off"), nav("globe", "peach", "Zen Browser", "Banners")] }] },
    sound: { desc: "PipeWire + WirePlumber audio devices.", groups: [
      { title: "Output", rows: [rng("volume", "pink", "Output volume", "vol"), val("headphones", "mauve", "Default output", "Active")] },
      { title: "Input", rows: [rng("mic", "red", "Input volume", "mic"), val("mic", "surface", "Default input", "Active")] }] },
    focus: { desc: "Silence notifications while you work, game or sleep.", groups: [
      [tog("moon", "mauve", "Do Not Disturb", "dnd"), nav("gamepad", "green", "Gaming", "When Steam is fullscreen"), nav("bulb", "yellow", "Sleep", "23:00 – 06:00")]] },
    screentime: { desc: "Daily usage summary.", groups: [
      [val("clock", "lavender", "Uptime", "@uptime"), val("globe", "peach", "Zen Browser", "2h 10m"), val("terminal", "mauve", "Ghostty", "1h 55m"), val("file", "blue", "Code - OSS", "1h 12m")]] },
    lockscreen: { desc: "Quickshell lock screen (ext-session-lock).", groups: [
      [tog("lock", "overlay", "Require password after sleep", "autoLock"), sel("clock", "overlay", "Clock style", "Large mono"), val("key", "overlay", "Authentication", "PAM · fprintd off")]] },
    privacy: { desc: "Portals, permissions and security.", groups: [
      [tog("globe", "blue", "Location Services", "location"), nav("mic", "red", "Microphone", "2 apps"), nav("scan", "overlay", "Screen Recording", "xdg-desktop-portal")],
      [tog("shield", "red", "Firewall", "firewall"), nav("key", "yellow", "Secure Boot", "sbctl · enabled")]] },
    users: { desc: "Local accounts on this PC.", groups: [
      [nav("user", "mauve", "@fullName", "Admin", "@userline"), nav("user", "surface", "Guest User", "Off")]] },
    keyboard: { desc: "Layout, repeat rate and shortcuts.", groups: [
      [sel("keyboard", "overlay", "Layout", "English (US)"), val("keyboard", "overlay", "Key repeat", "25 / 600 ms"), nav("list", "overlay", "Keyboard Shortcuts…", "niri binds")]] },
    mouse: { desc: "Pointer speed and scrolling (libinput).", groups: [
      [val("mouse", "overlay", "Tracking speed", "0.2"), tog("", "", "Natural scrolling", "natural"), tog("", "", "Pointer acceleration", "accel")]] },
    printers: { desc: "CUPS printers and SANE scanners.", groups: [
      [val("printer", "overlay", "No printers", "Add one with +"), nav("plus", "surface", "Add Printer, Scanner or Fax…")]] }
  })
}
