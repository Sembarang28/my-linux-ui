import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../components"

// Restart / Shut Down / Log Out confirmation with the 60 s countdown
PanelWindow {
  id: win
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  color: Qt.rgba(17/255, 17/255, 27/255, .55)
  visible: Sys.dialog !== ""
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  BackgroundEffect.blurRegion: Region { item: win.contentItem }

  property int left: 60
  onVisibleChanged: if (visible) left = 60
  Timer { interval: 1000; repeat: true; running: win.visible; onTriggered: { win.left--; if (win.left <= 0) Sys.confirmDialog() } }
  readonly property var cfg: ({
    restart: ["restart", "Are you sure you want to restart your computer now?", "Restart", "primary"],
    shutdown: ["power", "Are you sure you want to shut down your computer now?", "Shut Down", "danger"],
    logout: ["logout", "Are you sure you want to quit all applications and log out " + Sys.fullName + "?", "Log Out", "primary"] })[Sys.dialog] || ["info", "", "", ""]

  MouseArea { anchors.fill: parent; onClicked: Sys.dialog = "" }
  FocusScope {
    anchors.fill: parent; focus: true; Keys.onEscapePressed: Sys.dialog = ""
    PanelBox {
      anchors.centerIn: parent
      implicitWidth: 300; radius: 16; pad: 0
      Column {
        x: 0; width: parent.width + 0
        Item { width: 1; height: 22 }
        Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 54; height: 54; radius: 14; color: Theme.surface0
          Icon { anchors.centerIn: parent; name: win.cfg[0]; size: 26; color: Theme.accent } }
        Item { width: 1; height: 12 }
        T { width: parent.width - 40; x: 20; text: win.cfg[1]; font.pixelSize: 14; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap }
        Item { width: 1; height: 6 }
        T { width: parent.width - 40; x: 20; font.pixelSize: 12; color: Theme.overlay2; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
            text: "If you do nothing, the system will " + win.cfg[2].toLowerCase() + " automatically in " + win.left + " seconds." }
        Item { width: 1; height: 16 }
        Row { x: 20; spacing: 8; width: parent.width - 40
          Btn { width: (parent.width - 8) / 2; text: "Cancel"; onClicked: Sys.dialog = "" }
          Btn { width: (parent.width - 8) / 2; text: win.cfg[2]; kind: win.cfg[3]; onClicked: Sys.confirmDialog() } }
        Item { width: 1; height: 16 }
      }
    }
  }
}
