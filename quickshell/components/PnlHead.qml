import QtQuick
import "../services"

// .pnl-head: icon · title · meta (right slot)
Item {
  id: root
  property string icon: ""
  property color iconColor: Theme.accent
  property string title: ""
  property string meta: ""
  property bool monoMeta: false
  default property alias slot: rightRow.data
  width: parent ? parent.width : 300
  height: 22
  Row {
    spacing: 10; anchors.verticalCenter: parent.verticalCenter
    Icon { name: root.icon; size: 16; color: root.iconColor; anchors.verticalCenter: parent.verticalCenter }
    T { text: root.title; font.pixelSize: 14; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
  }
  Row { id: rightRow; anchors { right: parent.right; verticalCenter: parent.verticalCenter } spacing: 8
    T { visible: root.meta !== "" && !root.monoMeta; text: root.meta; color: Theme.overlay1; font.pixelSize: 11 }
    M { visible: root.meta !== "" && root.monoMeta; text: root.meta; color: Theme.overlay1; font.pixelSize: 11 }
  }
}
