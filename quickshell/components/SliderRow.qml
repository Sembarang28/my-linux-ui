import QtQuick
import "../services"

// .slider-row: icon · slider · value
Row {
  id: root
  property string icon: ""
  property real value: 0
  property real min: 0
  property real max: 100
  property string unit: "%"
  property color iconColor: Theme.subtext0
  property int valueWidth: 38
  property color fill: Theme.accent
  signal moved(real v)
  spacing: 10
  height: 22
  Icon { name: root.icon; size: 16; color: root.iconColor; anchors.verticalCenter: parent.verticalCenter; visible: root.icon !== "" }
  Slide {
    width: root.width - (root.icon !== "" ? 26 : 0) - root.valueWidth - 20
    value: root.value; min: root.min; max: root.max; fill: root.fill
    onMoved: v => root.moved(v)
  }
  M { width: root.valueWidth; horizontalAlignment: Text.AlignRight; text: Math.round(root.value) + root.unit
      color: Theme.subtext0; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
}
