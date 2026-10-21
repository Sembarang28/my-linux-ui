import QtQuick
import "../services"

// .li list item: round icon · title/sub · right slot
Rectangle {
  id: root
  property string icon: ""
  property string title: ""
  property string sub: ""
  property bool on: false
  property bool monoSub: false
  property color iconTone: "transparent"
  default property alias slot: rightRow.data
  signal clicked()
  width: parent ? parent.width : 300
  implicitHeight: 42; height: 42
  radius: 9
  color: ma.containsMouse ? Theme.hover5 : "transparent"
  Rectangle {
    id: ic
    x: 8; anchors.verticalCenter: parent.verticalCenter
    width: 28; height: 28; radius: 14
    color: root.on ? Theme.accent : Theme.surface0
    Icon { anchors.centerIn: parent; name: root.icon; size: 14; color: root.on ? Theme.crust : Theme.subtext1 }
  }
  Column {
    anchors { left: ic.right; leftMargin: 10; verticalCenter: parent.verticalCenter; right: rightRow.left; rightMargin: 8 }
    T { text: root.title; width: parent.width; elide: Text.ElideRight }
    Loader {
      active: root.sub !== ""
      sourceComponent: root.monoSub ? subM : subT
    }
  }
  Component { id: subT; T { text: root.sub; font.pixelSize: 11; color: Theme.overlay1; width: 200; elide: Text.ElideRight } }
  Component { id: subM; M { text: root.sub; font.pixelSize: 11; color: Theme.overlay1 } }
  Row { id: rightRow; anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter } spacing: 8 }
  MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; z: -1; onClicked: root.clicked() }
}
