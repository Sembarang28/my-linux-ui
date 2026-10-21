import QtQuick
import "../services"

Rectangle {
  id: root
  property string text: ""
  property string icon: ""
  signal clicked()
  implicitWidth: row.implicitWidth + 16; height: 28; radius: 7
  color: ma.containsMouse ? Theme.surface0 : "transparent"
  Row {
    id: row; anchors.centerIn: parent; spacing: 5
    Icon { visible: root.icon !== ""; name: root.icon; size: 13; color: ma.containsMouse ? Theme.text : Theme.subtext1; anchors.verticalCenter: parent.verticalCenter }
    T { visible: root.text !== ""; text: root.text; color: ma.containsMouse ? Theme.text : Theme.subtext1; anchors.verticalCenter: parent.verticalCenter }
  }
  MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
