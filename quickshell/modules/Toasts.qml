import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../components"

// Incoming notification banners, top-right under the bar
PanelWindow {
  id: win
  anchors { top: true; right: true }
  margins.top: Theme.barH + 14 + (Sys.flush ? 0 : 8)
  margins.right: 10
  implicitWidth: 370
  implicitHeight: Math.max(1, col.height)
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  visible: Notifs.toasts.length > 0 && Sys.panel !== "notifications"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region { item: col }
  BackgroundEffect.blurRegion: Region { item: col; radius: 14 }

  Column {
    id: col
    width: parent.width; spacing: 8
    Repeater {
      model: Notifs.toasts
      Rectangle {
        required property var modelData
        readonly property var tone: Notifs.iconFor(modelData.n)
        width: col.width; height: Math.max(62, tcol.implicitHeight + 24); radius: 14
        color: Theme.glassStrong; border.width: 1; border.color: Theme.hairline2
        Rectangle { x: 12; y: 12; width: 34; height: 34; radius: 10; color: Theme.c(tone[1]); Icon { anchors.centerIn: parent; name: tone[0]; size: 16; color: Theme.crust } }
        Column { id: tcol; x: 57; y: 12; width: parent.width - 69
          T { text: (modelData.n.appName || "").toUpperCase(); font.pixelSize: 10; font.weight: Font.Bold; color: Theme.overlay1; font.letterSpacing: 0.63 }
          T { text: modelData.n.summary; font.weight: Font.Bold; width: parent.width; elide: Text.ElideRight }
          T { visible: modelData.n.body !== ""; text: modelData.n.body; font.pixelSize: 12; color: Theme.subtext0; wrapMode: Text.Wrap; width: parent.width; maximumLineCount: 3; elide: Text.ElideRight } }
        MouseArea { anchors.fill: parent; onClicked: { modelData.toast = false; Notifs.refreshToasts(); Sys.openPanel("notifications", null) } }
      }
    }
  }
}
