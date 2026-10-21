import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "../../services"
import "../../components"

// Date & time panel: clock + weather on the left, month grid + today's events on the right
PanelBox {
  id: root
  implicitWidth: 680
  SystemClock { id: clk; precision: SystemClock.Seconds }
  readonly property date now: clk.date
  readonly property var wx: Sys.weather
  readonly property string greet: now.getHours() < 11 ? "Good morning" : now.getHours() < 15 ? "Good afternoon" : now.getHours() < 19 ? "Good evening" : "Good night"
  function p2(n) { return (n < 10 ? "0" : "") + n }
  function weekNo() { var y = now.getFullYear(), d0 = new Date(y, 0, 1); return Math.ceil(((now - d0) / 864e5 + d0.getDay() + 1) / 7) }
  readonly property var cells: {
    var y = now.getFullYear(), m = now.getMonth(), first = new Date(y, m, 1).getDay(), days = new Date(y, m + 1, 0).getDate(), prev = new Date(y, m, 0).getDate(), c = []
    for (var i = first - 1; i >= 0; i--) c.push({ d: prev - i, mute: true })
    for (var d = 1; d <= days; d++) c.push({ d: d, today: d === now.getDate(), we: ((first + d - 1) % 7) === 0 || ((first + d - 1) % 7) === 6 })
    while (c.length % 7) c.push({ d: c.length - days - first + 1, mute: true })
    return c
  }
  // optional ~/.config/quickshell/events.txt, one "HH:MM – HH:MM|Title" per line
  property var events: []
  FileView { path: Quickshell.shellPath("events.txt"); onLoaded: root.events = text().split("\n").filter(l => l.indexOf("|") > 0).map(l => l.split("|")) }

  Row {
    width: parent.width; spacing: 16
    // ---- left column ----
    Column {
      width: (parent.width - 16) / 2; spacing: 10
      Rectangle {
        width: parent.width; height: lc.implicitHeight + 28; radius: 14; color: Theme.card35; border.width: 1; border.color: Theme.hairline
        Column { id: lc; x: 16; y: 14; width: parent.width - 32
          T { text: root.greet + ", " + Sys.firstName; font.weight: Font.DemiBold; color: Theme.accent }
          Item { width: parent.width; height: 64 + 4
            Row { id: tr; y: 4
              T { id: tt; text: root.p2(root.now.getHours()) + ":" + root.p2(root.now.getMinutes()); font.pixelSize: 64; font.weight: Font.Bold; font.letterSpacing: -1.9; color: "white"
                  layer.enabled: true; layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text } }
              T { text: ":" + root.p2(root.now.getSeconds()); font.pixelSize: 26; color: Theme.overlay1; anchors.baseline: tt.baseline; leftPadding: 2 } }
          }
          Item { width: 1; height: 6 }
          T { text: Qt.formatDateTime(root.now, "dddd, MMM dd, yyyy"); font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.subtext1 }
          Item { width: 1; height: 10 }
          Row { spacing: 12
            Repeater {
              model: [["Jakarta", "WIB"], ["Tokyo", root.p2((root.now.getUTCHours() + 9) % 24) + ":" + root.p2(root.now.getUTCMinutes())], ["London", root.p2(root.now.getUTCHours()) + ":" + root.p2(root.now.getUTCMinutes())]]
              Row { required property var modelData; spacing: 4
                M { text: modelData[0]; font.pixelSize: 11; color: Theme.overlay1 }
                M { text: modelData[1]; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.subtext1 } } } }
        }
      }
      Rectangle {
        width: parent.width; height: wc.implicitHeight + 24; radius: 14; color: Theme.card35; border.width: 1; border.color: Theme.hairline
        Column { id: wc; x: 14; y: 12; width: parent.width - 28
          Item { width: parent.width; height: 84
            Column {
              Row { spacing: 5; Icon { name: "pin"; size: 13; color: Theme.subtext0; anchors.verticalCenter: parent.verticalCenter }
                    T { text: root.wx.city || "—"; font.weight: Font.DemiBold; color: Theme.subtext0 } }
              T { text: root.wx.ok ? root.wx.temp + "°" : "--"; font.pixelSize: 44; font.weight: Font.Bold; font.letterSpacing: -1.3 }
              T { text: root.wx.ok ? root.wx.cond + " · H " + root.wx.hi + "° L " + root.wx.lo + "°" : "Weather unavailable"; font.weight: Font.DemiBold; color: Theme.subtext1 } }
            Icon { anchors { right: parent.right; top: parent.top } name: root.wx.icon || "cloudSun"; size: 64; color: Theme.c(root.wx.color || "yellow") }
          }
          Item { width: 1; height: 10 }
          Row { spacing: 14; visible: root.wx.ok
            Repeater {
              model: [["thermo", "Feels " + root.wx.feels + "°"], ["droplet", root.wx.hum + "%"], ["wind", root.wx.wind + " km/h"]]
              Row { required property var modelData; spacing: 4
                Icon { name: modelData[0]; size: 13; color: Theme.overlay2; anchors.verticalCenter: parent.verticalCenter }
                T { text: modelData[1]; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.overlay2 } } } }
          Item { width: 1; height: 12 }
          Row { spacing: 6; width: parent.width
            Repeater {
              model: root.wx.hours || []
              Rectangle { required property var modelData; required property int index
                width: (parent.width - 30) / 6; height: 78; radius: 12
                color: index === 0 ? Theme.accentSoft : Theme.card35
                border.width: index === 0 ? 1 : 0; border.color: Theme.accentA(.35)
                Column { anchors.centerIn: parent; spacing: 5
                  T { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[0]; font.pixelSize: 11; font.weight: Font.DemiBold; color: index === 0 ? Theme.text : Theme.overlay2 }
                  Icon { anchors.horizontalCenter: parent.horizontalCenter; name: modelData[2]; size: 18; color: Theme.c(modelData[3]) }
                  M { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[1] + "°"; font.weight: Font.DemiBold } } } }
          }
        }
      }
    }
    // ---- right column ----
    Column {
      width: (parent.width - 16) / 2
      PnlHead { icon: "calendar"; title: Qt.formatDateTime(root.now, "MMMM yyyy"); meta: "Week " + root.weekNo() }
      Item { width: 1; height: 12 }
      Grid {
        columns: 7; rowSpacing: 2; columnSpacing: 2; width: parent.width
        Repeater { model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
          T { required property string modelData; width: (parent.width - 12) / 7; height: 21; text: modelData; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
              font.pixelSize: 10; font.weight: Font.DemiBold; color: Theme.overlay1 } }
        Repeater {
          model: root.cells
          Rectangle { required property var modelData
            width: (parent.width - 12) / 7; height: 28; radius: 7
            color: modelData.today ? Theme.accent : (dm.containsMouse ? Theme.surface0 : "transparent")
            M { anchors.centerIn: parent; text: modelData.d; font.weight: modelData.today ? Font.Bold : Font.Medium
                color: modelData.today ? Theme.crust : modelData.mute ? Theme.surface2 : modelData.we ? Theme.overlay2 : Theme.subtext1 }
            MouseArea { id: dm; anchors.fill: parent; hoverEnabled: true } }
        }
      }
      PnlSec { text: "Today" }
      Column { width: parent.width; spacing: 5
        Repeater {
          model: root.events
          Rectangle { required property var modelData; width: parent.width; height: 44; radius: 9; color: Theme.card45
            Rectangle { x: 10; y: 8; width: 3; height: 28; radius: 2; color: Theme.accent }
            Column { x: 23; anchors.verticalCenter: parent.verticalCenter
              T { text: modelData[1]; font.weight: Font.DemiBold }
              M { text: modelData[0]; font.pixelSize: 11; color: Theme.overlay1 } } }
        }
        T { visible: root.events.length === 0; text: "No events today"; color: Theme.overlay1; font.pixelSize: 12 }
      }
    }
  }
}
