import Quickshell
import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 440

  component Card: Rectangle {
    property string icon; property color tone; property string name; property real pct; property int temp; property string sub
    width: (parent.width - 16) / 3; height: col.implicitHeight + 20; radius: 12
    color: Theme.card; border.width: 1; border.color: Theme.hairline
    Column {
      id: col; x: 11; y: 10; width: parent.width - 22
      Row { spacing: 6; Icon { name: icon; size: 14; color: tone; anchors.verticalCenter: parent.verticalCenter }
            T { text: name; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.subtext0 } }
      Item { width: 1; height: 8 }
      Row { M { text: Math.round(pct); font.pixelSize: 22; font.weight: Font.Bold; font.letterSpacing: -0.44 }
            M { text: "%"; font.pixelSize: 12; color: Theme.overlay1; anchors.baseline: parent.children[0].baseline } }
      Item { width: 1; height: 3 }
      Row { spacing: 4; Icon { name: "thermo"; size: 11; color: Theme.overlay1; anchors.verticalCenter: parent.verticalCenter }
            M { text: temp ? temp + "°C" : "--"; font.pixelSize: 11; color: temp >= 65 ? Theme.peach : Theme.overlay1 } }
      Item { width: 1; height: 9 }
      Rectangle { width: parent.width; height: 5; radius: 3; color: Theme.surface0
        Rectangle { width: parent.width * Math.min(1, pct / 100); height: 5; radius: 3; color: tone; Behavior on width { NumberAnimation { duration: 600 } } } }
      Item { width: 1; height: 7 }
      M { text: sub; font.pixelSize: 11; color: Theme.overlay1 }
    }
  }

  Column {
    width: parent.width
    PnlHead { icon: "gauge"; title: "System Monitor"; meta: "up " + Sys.uptime + " · load " + Sys.load; monoMeta: true }
    Item { width: 1; height: 12 }
    Row {
      spacing: 8; width: parent.width
      Card { icon: "cpu"; tone: Theme.blue; name: "CPU"; pct: Sys.cpu; temp: Sys.cpuT; sub: (Sys.cpuMhz / 1000).toFixed(2) + " GHz" }
      Card { icon: "ram"; tone: Theme.green; name: "RAM"; pct: Sys.ram; temp: Sys.ramT; sub: Sys.ramUsed.toFixed(1) + "/" + Sys.ramTotal.toFixed(1) + "G" }
      Card { icon: "gpu"; tone: Theme.peach; name: "GPU"; pct: Sys.gpu; temp: Sys.gpuT; sub: (Sys.gpuPow > 0 ? Math.round(Sys.gpuPow) + " W · " : "") + Sys.gpuVram.toFixed(1) + "G" }
    }
    PnlSec { text: "CPU history · " + (Sys.specs.find(s => s[0] === "CPU") || ["", ""])[1] }
    Canvas {
      id: spark; width: parent.width; height: 54
      property var h: Sys.hist
      onHChanged: requestPaint()
      onPaint: {
        var c = getContext("2d"); c.reset()
        var n = h.length, step = width / (n - 1), pts = h.map((v, i) => [i * step, height - (v / 100) * height * 0.95])
        var g = c.createLinearGradient(0, 0, 0, height); g.addColorStop(0, "rgba(137,180,250,.35)"); g.addColorStop(1, "rgba(137,180,250,0)")
        c.beginPath(); c.moveTo(0, height); pts.forEach(p => c.lineTo(p[0], p[1])); c.lineTo(width, height); c.closePath(); c.fillStyle = g; c.fill()
        c.beginPath(); pts.forEach((p, i) => i ? c.lineTo(p[0], p[1]) : c.moveTo(p[0], p[1])); c.strokeStyle = "#89b4fa"; c.lineWidth = 1.6; c.stroke()
      }
    }
    Item { width: 1; height: 8 }
    Row {
      width: parent.width; height: 34; spacing: 3
      Repeater {
        model: Sys.cores.length ? Sys.cores : Array(20).fill(0)
        Rectangle {
          required property var modelData; required property int index
          width: (parent.width - 19 * 3) / 20; height: 34; radius: 2; color: Theme.surface0; clip: true
          Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: parent.height * Math.min(1, modelData / 100); radius: 2
                      color: index >= 16 ? Theme.sapphire : Theme.blue; opacity: index >= 16 ? .75 : 1; Behavior on height { NumberAnimation { duration: 600 } } }
        }
      }
    }
    PnlSec { text: "Memory, disk & network" }
    Grid {
      columns: 2; spacing: 6; width: parent.width
      Repeater {
        model: [["layers", "Swap", Sys.swapUsed.toFixed(2) + " / " + Sys.swapTotal.toFixed(2) + " GiB"],
                ["disk", "/", Sys.diskUsed.toFixed(1) + " / " + Sys.diskTotal.toFixed(1) + " GiB"],
                ["arrows", "Network", "↓ " + Sys.fmtRate(Sys.netDown) + "  ↑ " + Sys.fmtRate(Sys.netUp)],
                ["fan", "GPU fan · VRAM", Sys.gpuFan + "% · " + Sys.gpuVram.toFixed(1) + " / " + Sys.gpuVramTotal.toFixed(0) + " GiB"]]
        Rectangle { required property var modelData; width: (parent.width - 6) / 2; height: 46; radius: 10; color: Qt.rgba(49/255, 50/255, 68/255, .4)
          Icon { x: 10; anchors.verticalCenter: parent.verticalCenter; name: modelData[0]; size: 15; color: Theme.overlay2 }
          Column { x: 33; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 40
            T { text: modelData[1]; font.pixelSize: 11; color: Theme.overlay1 }
            M { text: modelData[2]; font.weight: Font.DemiBold; width: parent.width; elide: Text.ElideRight } } }
      }
    }
    PnlSec { text: "Top processes" }
    Grid {
      columns: 3; columnSpacing: 8; rowSpacing: 4; width: parent.width
      T { text: "Name"; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.overlay1; width: parent.width - 60 - 70 - 16 }
      T { text: "CPU"; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.overlay1; width: 60; horizontalAlignment: Text.AlignRight }
      T { text: "Memory"; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.overlay1; width: 70; horizontalAlignment: Text.AlignRight }
      Repeater {
        model: Sys.procs.slice(0, 6).reduce((a, p) => a.concat([p[0], p[1] + "%", (Number(p[2]) / 1048576 >= 1 ? (Number(p[2]) / 1048576).toFixed(2) + " GiB" : Math.round(Number(p[2]) / 1024) + " MiB")]), [])
        M { required property string modelData; required property int index
            text: modelData; font.pixelSize: 11; color: Theme.subtext0; elide: Text.ElideRight
            width: index % 3 === 0 ? parent.width - 60 - 70 - 16 : (index % 3 === 1 ? 60 : 70)
            horizontalAlignment: index % 3 === 0 ? Text.AlignLeft : Text.AlignRight }
      }
    }
    PnlFoot {
      LinkBtn { text: "Open btop"; onClicked: { Sys.close(); Quickshell.execDetached(["ghostty", "-e", "btop"]) } }
      LinkBtn { text: "Mission Center"; onClicked: { Sys.close(); Quickshell.execDetached(["missioncenter"]) } }
    }
  }
}
