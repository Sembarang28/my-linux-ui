import Quickshell.Io
import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 320
  property string governor: "—"
  Process { running: true; command: ["cat", "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"]
            stdout: StdioCollector { onStreamFinished: root.governor = text.trim() || "—" } }
  readonly property var opts: [
    { id: "power-saver", n: "Power Saver", i: "battery", c: "green", s: "Lower clocks, quieter fans" },
    { id: "balanced", n: "Balanced", i: "gauge", c: "mauve", s: "Default for everyday use" },
    { id: "performance", n: "Performance", i: "zap", c: "peach", s: "Max clocks for gaming & builds" }]
  Column {
    width: parent.width
    PnlHead { icon: "gauge"; title: "Power Mode"; meta: "power-profiles-daemon" }
    Item { width: 1; height: 12 }
    Column {
      width: parent.width; spacing: 6
      Repeater {
        model: root.opts
        Rectangle {
          required property var modelData
          readonly property bool sel: Sys.profile === modelData.id
          readonly property color oc: Theme.c(modelData.c)
          width: parent.width; height: 56; radius: 12
          color: sel ? Qt.rgba(oc.r, oc.g, oc.b, .12) : (om.containsMouse ? Qt.rgba(49/255, 50/255, 68/255, .6) : Theme.card35)
          border.width: 1; border.color: sel ? Qt.rgba(oc.r, oc.g, oc.b, .45) : "transparent"
          Rectangle { x: 12; anchors.verticalCenter: parent.verticalCenter; width: 32; height: 32; radius: 10; color: sel ? oc : Theme.surface1
            Icon { anchors.centerIn: parent; name: modelData.i; size: 16; color: sel ? Theme.crust : Theme.subtext1 } }
          Column { x: 56; anchors.verticalCenter: parent.verticalCenter
            T { text: modelData.n; font.weight: Font.Bold }
            T { text: modelData.s; font.pixelSize: 11; color: Theme.overlay1 } }
          Rectangle { anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter } width: 18; height: 18; radius: 9
            color: "transparent"; border.width: 2; border.color: sel ? oc : Theme.surface2
            Rectangle { anchors.centerIn: parent; width: 12; height: 12; radius: 6; color: oc; visible: sel } }
          MouseArea { id: om; anchors.fill: parent; hoverEnabled: true; onClicked: Sys.setProfile(modelData.id) }
        }
      }
    }
    Item { width: 1; height: 12 }
    Grid {
      columns: 2; spacing: 6; width: parent.width
      Repeater {
        model: [["cpu", "Governor", root.governor], ["zap", "CPU clock", (Sys.cpuMhz / 1000).toFixed(2) + " GHz"]]
        Rectangle { required property var modelData; width: (parent.width - 6) / 2; height: 44; radius: 10; color: Qt.rgba(49/255, 50/255, 68/255, .4)
          Icon { x: 10; anchors.verticalCenter: parent.verticalCenter; name: modelData[0]; size: 15; color: Theme.overlay2 }
          Column { x: 33; anchors.verticalCenter: parent.verticalCenter
            T { text: modelData[1]; font.pixelSize: 11; color: Theme.overlay1 }
            M { text: modelData[2]; font.weight: Font.DemiBold } } }
      }
    }
  }
}
