pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Persisted shell preferences (~/.config/quickshell/state.json)
Singleton {
  id: root
  property string accent: "mauve"
  property string wall: "unix"
  property bool night: false
  property int nightTemp: 4500
  property bool dnd: false
  property bool caffeine: false
  property bool reduceTrans: false
  property bool showStats: true
  property bool showNotif: true
  property bool showPower: true
  property bool showBri: true
  property bool showSound: true
  property bool showBt: true
  property bool showWifi: true
  property bool showSeconds: false
  // settings-only switches
  property bool autojoin: true
  property bool firewall: true
  property bool wg: false
  property bool ts: true
  property bool zoom: false
  property bool reduceMotion: false
  property bool scroll: true
  property bool hotcorner: true
  property bool anims: true
  property bool centerCol: true
  property bool preview: true
  property bool notifSound: true
  property bool natural: true
  property bool accel: false
  property bool autoLock: true
  property bool location: false
  property bool vrr: true

  readonly property var keys: ["accent", "wall", "night", "nightTemp", "dnd", "caffeine", "reduceTrans", "showStats", "showNotif", "showPower", "showBri", "showSound", "showBt", "showWifi", "showSeconds",
    "autojoin", "firewall", "wg", "ts", "zoom", "reduceMotion", "scroll", "hotcorner", "anims", "centerCol", "preview", "notifSound", "natural", "accel", "autoLock", "location", "vrr"]
  property bool loaded: false

  function set(k, v) { root[k] = v; save() }
  function toggle(k) { set(k, !root[k]) }
  function save() { if (loaded) saveTimer.restart() }
  Timer {
    id: saveTimer; interval: 400
    onTriggered: { var o = {}; root.keys.forEach(k => o[k] = root[k]); file.setText(JSON.stringify(o, null, 2)) }
  }
  FileView {
    id: file
    path: Quickshell.shellPath("state.json")
    onLoaded: {
      try { var o = JSON.parse(text()); root.keys.forEach(k => { if (o[k] !== undefined) root[k] = o[k] }) } catch (e) {}
      root.loaded = true
    }
    onLoadFailed: root.loaded = true
  }
}
