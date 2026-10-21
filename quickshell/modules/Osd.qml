import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../components"

// Volume / brightness pill after the hardware keys (shellctl.sh osd …)
PanelWindow {
  id: win
  anchors { bottom: true; left: true; right: true }
  margins.bottom: 70
  implicitHeight: hud.height
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  visible: hud.opacity > 0
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region { item: hud }
  BackgroundEffect.blurRegion: Region { item: hud; radius: 14 }

  readonly property bool isVol: Sys.osd === "volume"
  readonly property real level: isVol ? Sys.volume : Sys.brightness
  readonly property bool silent: isVol && Sys.muted

  Rectangle {
    id: hud
    anchors.horizontalCenter: parent.horizontalCenter
    width: 280; height: 48; radius: 14
    color: Theme.glassStrong; border.width: 1; border.color: Theme.hairline2
    opacity: Sys.osd !== "" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 180 } }
    Row {
      anchors.centerIn: parent; spacing: 12
      Icon { name: win.isVol ? (win.silent ? "x" : "volume") : "sun"; size: 18; color: win.isVol ? Theme.pink : Theme.yellow; anchors.verticalCenter: parent.verticalCenter }
      Item { width: 170; height: 22; anchors.verticalCenter: parent.verticalCenter
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 8; radius: 4; color: Theme.surface0
          Rectangle { width: parent.width * Math.min(1, win.level / 100) * (win.silent ? 0 : 1); height: 8; radius: 4; color: Theme.accent } } }
      M { text: win.silent ? "mute" : Math.round(win.level) + "%"; width: 38; horizontalAlignment: Text.AlignRight; color: Theme.subtext0; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
    }
  }
}
