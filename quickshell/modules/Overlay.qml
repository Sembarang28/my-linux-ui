import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../components"
import "panels"

// Hosts whichever bar panel / menu is open, below the bar, and closes it on an outside click
PanelWindow {
  id: win
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  visible: Sys.panel !== ""
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: Sys.panel === "launcher" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
  BackgroundEffect.blurRegion: Region { item: blurRect; radius: 14 }
  Item { id: blurRect; visible: false; x: loader.x; y: loader.y; width: loader.item ? loader.item.width : 0; height: loader.item ? loader.item.height : 0 }

  MouseArea { anchors.fill: parent; onClicked: Sys.close() }

  readonly property bool isMenu: Sys.panel === "arch" || Sys.panel.indexOf("menu:") === 0
  Component { id: arch; ArchMenu {} }
  Component { id: appMenu; AppMenu { name: Sys.panel.slice(5) } }
  Component { id: stats; Stats {} }
  Component { id: notifs; Notifications {} }
  Component { id: power; Power {} }
  Component { id: bri; Brightness {} }
  Component { id: sound; Sound {} }
  Component { id: bt; Bluetooth {} }
  Component { id: wifi; Wifi {} }
  Component { id: quick; Quick {} }
  Component { id: cal; Calendar {} }
  Component { id: launcher; Launcher {} }
  readonly property var map: ({ arch: arch, stats: stats, notifications: notifs, power: power, brightness: bri, sound: sound, bluetooth: bt, wifi: wifi, quick: quick, calendar: cal, launcher: launcher })

  FocusScope {
    anchors.fill: parent; focus: true
    Keys.onEscapePressed: Sys.close()
    Loader {
      id: loader
      sourceComponent: Sys.panel.indexOf("menu:") === 0 ? appMenu : (win.map[Sys.panel] || null)
      readonly property real topY: Sys.flush ? Theme.barH + 6 : 8 + Theme.barH + 6
      y: Sys.panel === "launcher" ? win.height * 0.18 : topY
      x: {
        if (!item) return 0
        if (Sys.panel === "launcher") return (win.width - item.width) / 2
        var right = Sys.anchorX + Sys.anchorW / 2 > win.width / 2
        var l = right ? Sys.anchorX + Sys.anchorW - item.width : Sys.anchorX
        return Math.max(10, Math.min(win.width - item.width - 10, l))
      }
      Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }
  }
}
