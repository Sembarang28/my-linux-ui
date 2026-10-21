import Quickshell
import QtQuick
import "../services"
import "../components"

FloatingWindow {
  id: win
  title: "Force Quit Applications"
  visible: Sys.forceQuitOpen
  color: "transparent"
  implicitWidth: 380; implicitHeight: col.implicitHeight + 40 + 18
  onVisibleChanged: { if (visible) sel = -1; else Sys.forceQuitOpen = false }
  property int sel: -1
  readonly property var apps: Sys.windows.map(w => ({ id: w.id, pid: w.pid, name: Sys.appName(w.app_id, w.title), title: w.title }))

  WinFrame {
    anchors.fill: parent; title: "Force Quit Applications"; onCloseRequested: Sys.forceQuitOpen = false
    Column {
      id: col; y: 40; x: 18; width: parent.width - 36
      T { width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 12; color: Theme.overlay2; lineHeight: 1.2
          text: "If an app doesn't respond for a while, select its name and click Force Quit." }
      Item { width: 1; height: 8 }
      Rectangle {
        width: parent.width; height: Math.max(40, Math.min(260, win.apps.length * 42)); radius: 10; color: "transparent"; border.width: 1; border.color: Theme.hairline2; clip: true
        ListView {
          anchors.fill: parent; model: win.apps; interactive: contentHeight > height
          delegate: Rectangle {
            required property var modelData; required property int index
            width: ListView.view.width; height: 42
            color: win.sel === index ? Theme.accent : "transparent"
            TileIc { x: 10; anchors.verticalCenter: parent.verticalCenter; box: 24; glyph: 13; icon: "terminal"; tone: ["mauve", "peach", "blue", "green", "lavender", "sky", "pink"][index % 7] }
            T { x: 44; anchors.verticalCenter: parent.verticalCenter; text: modelData.name; color: win.sel === index ? Theme.crust : Theme.text; width: parent.width - 120; elide: Text.ElideRight }
            M { anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter } text: "pid " + modelData.pid; font.pixelSize: 11; color: win.sel === index ? Theme.crust : Theme.overlay1 }
            MouseArea { anchors.fill: parent; onClicked: win.sel = index }
          }
        }
      }
      Item { width: 1; height: 14 }
      Row { anchors.right: parent.right; spacing: 8
        Btn { text: "Cancel"; onClicked: Sys.forceQuitOpen = false }
        Btn { text: "Force Quit"; kind: "danger"; onClicked: { if (win.sel >= 0) Quickshell.execDetached(["kill", "-9", String(win.apps[win.sel].pid)]); Sys.forceQuitOpen = false } } }
    }
  }
}
