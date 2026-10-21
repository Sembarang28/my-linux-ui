import QtQuick
import "../services"

// input[type=range]: 8px track filled with accent, 18px thumb with base ring
Item {
  id: root
  property real value: 0          // min..max
  property real min: 0
  property real max: 100
  property color fill: Theme.accent
  signal moved(real v)
  implicitHeight: 22; implicitWidth: 160; height: 22
  readonly property real frac: Math.max(0, Math.min(1, (value - min) / (max - min)))
  function setFrom(x) {
    var f = Math.max(0, Math.min(1, (x - 9) / (width - 18)))
    value = Math.round(min + f * (max - min)); moved(value)
  }
  Rectangle {
    id: track
    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
    height: 8; radius: 4; color: Theme.surface0
    Rectangle { width: Math.max(8, 9 + (parent.width - 18) * root.frac); height: parent.height; radius: 4; color: root.fill }
  }
  Rectangle {
    x: (root.width - 18) * root.frac; anchors.verticalCenter: parent.verticalCenter
    width: 18; height: 18; radius: 9; color: Theme.text
    border.width: 3; border.color: "transparent"
    Rectangle { anchors.centerIn: parent; width: 24; height: 24; radius: 12; color: "transparent"; border.width: 3; border.color: Theme.base; z: -1 }
  }
  MouseArea {
    anchors.fill: parent
    onPressed: m => root.setFrom(m.x)
    onPositionChanged: m => { if (pressed) root.setFrom(m.x) }
    onWheel: w => { root.value = Math.max(root.min, Math.min(root.max, root.value + (w.angleDelta.y > 0 ? 5 : -5))); root.moved(root.value) }
  }
}
