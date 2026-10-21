pragma Singleton
import Quickshell
import QtQuick

// Catppuccin Mocha tokens, copied 1:1 from mocha-shell.html
Singleton {
  readonly property var palette: ({
    rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7",
    red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387", yellow: "#f9e2af",
    green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec",
    blue: "#89b4fa", lavender: "#b4befe", overlay: "#9399b2", surface: "#585b70"
  })
  function c(name) { return palette[name] || name }

  readonly property color rosewater: "#f5e0dc"
  readonly property color flamingo: "#f2cdcd"
  readonly property color pink: "#f5c2e7"
  readonly property color mauve: "#cba6f7"
  readonly property color red: "#f38ba8"
  readonly property color maroon: "#eba0ac"
  readonly property color peach: "#fab387"
  readonly property color yellow: "#f9e2af"
  readonly property color green: "#a6e3a1"
  readonly property color teal: "#94e2d5"
  readonly property color sky: "#89dceb"
  readonly property color sapphire: "#74c7ec"
  readonly property color blue: "#89b4fa"
  readonly property color lavender: "#b4befe"
  readonly property color text: "#cdd6f4"
  readonly property color subtext1: "#bac2de"
  readonly property color subtext0: "#a6adc8"
  readonly property color overlay2: "#9399b2"
  readonly property color overlay1: "#7f849c"
  readonly property color overlay0: "#6c7086"
  readonly property color surface2: "#585b70"
  readonly property color surface1: "#45475a"
  readonly property color surface0: "#313244"
  readonly property color base: "#1e1e2e"
  readonly property color mantle: "#181825"
  readonly property color crust: "#11111b"

  readonly property color accent: palette[Prefs.accent] || mauve
  readonly property color accentSoft: Qt.rgba(accent.r, accent.g, accent.b, 0.16)
  function accentA(a) { return Qt.rgba(accent.r, accent.g, accent.b, a) }

  readonly property color glass: Prefs.reduceTrans ? "#f2111118" : Qt.rgba(17/255, 17/255, 27/255, .42)
  readonly property color glassStrong: Prefs.reduceTrans ? "#f2181825" : Qt.rgba(24/255, 24/255, 37/255, .62)
  readonly property color glassWin: Prefs.reduceTrans ? "#f21e1e2e" : Qt.rgba(30/255, 30/255, 46/255, .68)
  readonly property color hairline: Qt.rgba(205/255, 214/255, 244/255, .07)
  readonly property color hairline2: Qt.rgba(205/255, 214/255, 244/255, .11)
  readonly property color hover: Qt.rgba(205/255, 214/255, 244/255, .07)
  readonly property color hover5: Qt.rgba(205/255, 214/255, 244/255, .05)
  readonly property color card: Qt.rgba(49/255, 50/255, 68/255, .55)
  readonly property color card35: Qt.rgba(49/255, 50/255, 68/255, .35)
  readonly property color card45: Qt.rgba(49/255, 50/255, 68/255, .45)
  readonly property color card60: Qt.rgba(49/255, 50/255, 68/255, .60)
  readonly property color wsTrack: Qt.rgba(17/255, 17/255, 27/255, .55)

  readonly property string ui: "Quicksand"
  readonly property string mono: "JetBrainsMono Nerd Font"
  readonly property int barH: 36
}
