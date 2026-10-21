import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 370
  Column {
    width: parent.width
    PnlHead { icon: "bell"; iconColor: Theme.red; title: "Notifications"
      T { text: "Do Not Disturb"; color: Theme.overlay1; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
      Sw { on: Prefs.dnd; onToggled: Prefs.toggle("dnd") } }
    Item { width: 1; height: 12 }
    Column {
      width: parent.width; spacing: 7
      Repeater {
        model: Notifs.items
        Rectangle {
          required property var modelData
          readonly property var tone: Notifs.iconFor(modelData.n)
          width: parent.width; height: Math.max(58, col.implicitHeight + 22); radius: 13
          color: Theme.card45 ; border.width: 1; border.color: Theme.hairline
          Rectangle { x: 12; y: 11; width: 34; height: 34; radius: 10; color: Theme.c(tone[1])
            Icon { anchors.centerIn: parent; name: tone[0]; size: 16; color: Theme.crust } }
          Column {
            id: col; x: 57; y: 11; width: parent.width - 57 - 36; spacing: 1
            T { text: (modelData.n.appName || "").toUpperCase(); font.pixelSize: 10; font.weight: Font.Bold; color: Theme.overlay1; font.letterSpacing: 0.63 }
            Row { width: parent.width
              T { text: modelData.n.summary; font.weight: Font.Bold; width: parent.width - tm.implicitWidth - 8; elide: Text.ElideRight }
              T { id: tm; text: Notifs.timeAgo(modelData.time); font.pixelSize: 11; color: Theme.overlay1; leftPadding: 8 }
            }
            T { visible: modelData.n.body !== ""; text: modelData.n.body; font.pixelSize: 12; color: Theme.subtext0; wrapMode: Text.Wrap; width: parent.width; maximumLineCount: 3; elide: Text.ElideRight }
          }
          Rectangle { anchors { right: parent.right; rightMargin: 8; top: parent.top; topMargin: 8 } width: 22; height: 22; radius: 6
            color: xm.containsMouse ? Theme.surface0 : "transparent"
            Icon { anchors.centerIn: parent; name: "x"; size: 13; color: Theme.subtext1 }
            MouseArea { id: xm; anchors.fill: parent; hoverEnabled: true; onClicked: Notifs.dismiss(modelData.n) } }
        }
      }
    }
    Item { visible: Notifs.count === 0; width: parent.width; height: 26 + 28 + 8 + 20 + 26
      Column { anchors.centerIn: parent; spacing: 8
        Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "bell"; size: 28; color: Theme.surface2 }
        T { text: "No new notifications"; color: Theme.overlay1 } } }
    PnlFoot {
      LinkBtn { text: "Clear All"; onClicked: Notifs.clearAll() }
      LinkBtn { text: "Notification Settings…"; onClicked: Sys.doAction("settings:notifications") }
    }
  }
}
