import QtQuick
import "../services"

// .btn / .btn.primary / .btn.danger
Rectangle {
  id: root
  property string text: ""
  property string kind: ""     // "" | primary | danger
  signal clicked()
  implicitWidth: lbl.implicitWidth + 28; implicitHeight: 28; height: 28; radius: 8
  color: kind === "primary" ? Theme.accent : kind === "danger" ? Theme.red : (ma.containsMouse ? Theme.surface1 : Theme.surface0)
  border.width: kind === "" ? 1 : 0; border.color: Theme.hairline2
  scale: ma.pressed ? 0.98 : 1
  T { id: lbl; anchors.centerIn: parent; text: root.text; font.weight: Font.DemiBold; color: root.kind === "" ? Theme.text : Theme.crust }
  Rectangle { anchors.fill: parent; radius: parent.radius; color: "white"; opacity: root.kind !== "" && ma.containsMouse ? 0.08 : 0 }
  MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
