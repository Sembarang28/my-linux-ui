import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../components"

// Top bar. Floats (8px margin, 12px radius) on an empty desktop and snaps flush to the
// screen edges while a full-size window is on the workspace, like #bar / body.bar-flush.
PanelWindow {
  id: win
  anchors { top: true; left: true; right: true }
  implicitHeight: 8 + Theme.barH
  exclusiveZone: Theme.barH
  color: "transparent"
  mask: Region { item: strip }
  BackgroundEffect.blurRegion: Region { item: strip; radius: strip.radius }

  SystemClock { id: clock; precision: Prefs.showSeconds ? SystemClock.Seconds : SystemClock.Minutes }
  readonly property bool flush: Sys.flush
  readonly property var menuNames: ["File", "Edit", "View", "Go", "Window", "Help"]

  Rectangle {
    id: strip
    x: win.flush ? 0 : 10
    y: win.flush ? 0 : 8
    width: parent.width - (win.flush ? 0 : 20)
    height: Theme.barH
    radius: win.flush ? 0 : 12
    color: Theme.glass
    border.width: 1; border.color: Theme.hairline
    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 300 } }
    Rectangle { x: parent.radius; y: 1; width: parent.width - parent.radius * 2; height: 1; color: "#0dffffff"; visible: !win.flush }

    // ---------------- left ----------------
    Row {
      anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
      spacing: 2

      BarBtn { panel: "arch"; icon: "arch"; iconSize: 17; padX: 10; tone: Theme.blue; toneHover: Theme.sky; menuLike: true }

      // only the active workspace number
      Item {
        width: Math.max(30, wsNum.implicitWidth + 12) + 8; height: parent.height
        Rectangle { anchors.centerIn: parent; width: parent.width - 8 + 6; height: 26; radius: 9; color: Theme.wsTrack }
        Rectangle { anchors.centerIn: parent; width: parent.width - 8; height: 20; radius: 6; color: Theme.accent }
        M { id: wsNum; anchors.centerIn: parent; text: Sys.activeWsIdx; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.crust }
        WheelHandler { onWheel: e => Sys.wsStep(e.angleDelta.y < 0 ? 1 : -1) }
      }

      T { text: Sys.focusedApp; font.weight: Font.Bold; font.letterSpacing: -0.13; anchors.verticalCenter: parent.verticalCenter
          leftPadding: 0; width: Math.min(implicitWidth, 260) + 14; elide: Text.ElideRight }

      Repeater {
        model: win.menuNames
        BarBtn { required property string modelData; panel: "menu:" + modelData; text: modelData; menuLike: true }
      }
      M { anchors.verticalCenter: parent.verticalCenter; leftPadding: 8; text: Sys.wsTotal; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.overlay1 }
    }

    // ---------------- right ----------------
    Row {
      anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
      spacing: 2

      // stats chip
      Item {
        visible: Prefs.showStats
        width: chip.width; height: 26
        BarBtn { id: chip; panel: "stats"; padX: 4
          Row {
            Repeater {
              model: [["cpu", "blue", Sys.cpu, Sys.cpuT], ["ram", "green", Sys.ram, Sys.ramT], ["gpu", "peach", Sys.gpu, Sys.gpuT]]
              Item {
                required property var modelData
                required property int index
                width: pr.implicitWidth + 14; height: 20
                Rectangle { visible: index > 0; width: 1; height: 20; color: Theme.hairline2 }
                Row {
                  id: pr; anchors.centerIn: parent; spacing: 5
                  Icon { name: modelData[0]; size: 13; color: Theme.c(modelData[1]); anchors.verticalCenter: parent.verticalCenter }
                  M { text: String(Math.round(modelData[2])).padStart(2, " ") + "%"; font.pixelSize: 11; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                  M { text: modelData[3] ? Math.round(modelData[3]) + "°" : "--"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter
                      color: modelData[3] >= 80 ? Theme.red : modelData[3] >= 65 ? Theme.peach : Theme.overlay2 }
                }
              }
            }
          }
        }
      }

      BarBtn { visible: Prefs.showNotif; panel: "notifications"; icon: Prefs.dnd ? "moon" : "bell"; padX: 8; badge: Prefs.dnd ? 0 : Notifs.count }
      BarBtn { visible: Prefs.showPower; panel: "power"; icon: Sys.profile === "power-saver" ? "battery" : Sys.profile === "performance" ? "zap" : "gauge"
               tone: Sys.profile === "power-saver" ? Theme.green : Sys.profile === "performance" ? Theme.peach : Theme.subtext1
               toneHover: tone === Theme.subtext1 ? Theme.text : tone }
      BarBtn { visible: Prefs.showBri; panel: "brightness"; icon: Sys.brightness < 40 ? "sunDim" : "sun"; onWheeled: d => Sys.setBrightness(Sys.brightness + (d > 0 ? 5 : -5)) }
      BarBtn { visible: Prefs.showSound; panel: "sound"; icon: Sys.muted ? "x" : "volume"; onWheeled: d => Sys.setVolume(Math.max(0, Math.min(100, Sys.volume + (d > 0 ? 5 : -5)))) }
      BarBtn { visible: Prefs.showBt; panel: "bluetooth"; icon: "bluetooth"; off: !Sys.bt }
      BarBtn { visible: Prefs.showWifi; panel: "wifi"; icon: Sys.wifi ? "wifi" : "wifiOff"; off: !Sys.wifi }
      BarBtn { panel: "quick"; icon: "sliders" }

      BarBtn {
        panel: "calendar"; padX: 11
        Row {
          spacing: 8
          M { text: Qt.formatDateTime(clock.date, "dddd, MMM dd, yyyy"); font.weight: Font.DemiBold; }
          M { text: Qt.formatDateTime(clock.date, Prefs.showSeconds ? "HH:mm:ss" : "HH:mm"); font.weight: Font.DemiBold; color: Theme.accent }
        }
      }
    }
  }
}
