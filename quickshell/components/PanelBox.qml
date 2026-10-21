import QtQuick
import QtQuick.Effects
import "../services"

// .panel: glass card with hairline border, top highlight and the "pop" animation
Item {
  id: root
  property int radius: 14
  property color fill: Theme.glassStrong
  property int pad: 14
  default property alias content: body.data
  property alias bodyItem: body
  implicitWidth: 340
  implicitHeight: body.childrenRect.height + pad * 2
  transformOrigin: Item.Top

  Rectangle {
    anchors.fill: parent; radius: root.radius; color: root.fill
    border.width: 1; border.color: Theme.hairline2
    Rectangle { anchors { top: parent.top; topMargin: 1; left: parent.left; leftMargin: root.radius; right: parent.right; rightMargin: root.radius } height: 1; color: "#0dffffff" }
  }
  Item { id: body; x: root.pad; y: root.pad; width: root.width - root.pad * 2; height: childrenRect.height }
  MouseArea { anchors.fill: parent; z: -1 }    // swallow clicks inside the panel

  opacity: 0
  property real dy: -6
  transform: Translate { y: root.dy }
  scale: 0.98
  Component.onCompleted: pop.start()
  ParallelAnimation {
    id: pop
    NumberAnimation { target: root; property: "opacity"; to: 1; duration: 160 }
    NumberAnimation { target: root; property: "dy"; to: 0; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    NumberAnimation { target: root; property: "scale"; to: 1; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
  }
}
