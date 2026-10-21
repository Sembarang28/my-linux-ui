import QtQuick
import "../services"

// .menu-item: macOS style row (accent fill on hover)
Item {
  id: root
  property string label: ""
  property string icon: ""
  property string kbd: ""
  property bool disabled: false
  property bool hasSub: false
  property bool open: false
  signal clicked()
  signal entered()
  width: parent ? parent.width : 240
  height: 26
  readonly property bool hot: !disabled && (ma.containsMouse || open)
  Rectangle { anchors.fill: parent; radius: 6; color: root.hot ? Theme.accent : "transparent" }
  Row {
    x: 10; spacing: 10; anchors.verticalCenter: parent.verticalCenter
    Item { width: 15; height: 15; visible: root.icon !== ""
      Icon { anchors.centerIn: parent; name: root.icon; size: 14; color: root.hot ? Theme.crust : Theme.overlay2; opacity: root.hot ? 0.75 : 1 } }
    T { text: root.label; color: root.disabled ? Theme.overlay0 : (root.hot ? Theme.crust : Theme.text) }
  }
  M { visible: root.kbd !== ""; anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
      text: root.kbd; font.pixelSize: 11; font.letterSpacing: 0.44; color: root.hot ? Theme.crust : Theme.overlay1; opacity: root.hot ? 0.75 : 1 }
  Icon { visible: root.hasSub; anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
         name: "chevR"; size: 13; color: root.hot ? Theme.crust : Theme.overlay1 }
  MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onEntered: root.entered(); onClicked: if (!root.disabled) root.clicked() }
}
