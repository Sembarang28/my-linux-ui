import QtQuick
import "../services"

// .switch 34x20
Item {
  id: root
  property bool on: false
  signal toggled()
  implicitWidth: 34; implicitHeight: 20; width: 34; height: 20
  Rectangle {
    anchors.fill: parent; radius: 10
    color: root.on ? Theme.accent : Theme.surface1
    Behavior on color { ColorAnimation { duration: 200 } }
    Rectangle {
      y: 2; width: 16; height: 16; radius: 8
      x: root.on ? 16 : 2
      color: root.on ? Theme.crust : Theme.text
      Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 200 } }
    }
  }
  MouseArea { anchors.fill: parent; onClicked: root.toggled() }
}
