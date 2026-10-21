import QtQuick
import "../services"

// .bar-btn (26px tall, 8px radius). `panel` is the name opened in the overlay.
Item {
  id: root
  property string panel: ""
  property string icon: ""
  property int iconSize: 15
  property string text: ""
  property color tone: Theme.subtext1
  property color toneHover: Theme.text
  property bool off: false
  property bool bold: false
  property int padX: 8
  property bool menuLike: false
  property int badge: 0
  property bool plain: false          // no panel, just a click signal
  property bool activeOverride: false
  default property alias extra: extraRow.data
  signal clicked()
  signal wheeled(int d)
  readonly property bool active: panel !== "" && Sys.panel === panel
  height: 26
  width: row.implicitWidth + padX * 2

  Rectangle {
    anchors.fill: parent; radius: 8
    color: root.active ? Theme.surface0 : (ma.containsMouse ? Theme.hover : "transparent")
    border.width: root.active ? 1 : 0; border.color: Theme.hairline2
  }
  Row {
    id: row
    anchors.centerIn: parent; spacing: 6
    Icon { visible: root.icon !== ""; name: root.icon; size: root.iconSize
           color: root.off ? Theme.overlay0 : ((ma.containsMouse || root.active) ? root.toneHover : root.tone)
           anchors.verticalCenter: parent.verticalCenter }
    T { visible: root.text !== ""; text: root.text; font.weight: root.bold ? Font.Bold : Font.Medium
        color: (ma.containsMouse || root.active) ? Theme.text : root.tone; anchors.verticalCenter: parent.verticalCenter }
    Row { id: extraRow; anchors.verticalCenter: parent.verticalCenter; spacing: 0 }
  }
  Rectangle {
    visible: root.badge > 0
    x: parent.width - width - 4; y: 3
    width: Math.max(14, bt.implicitWidth + 6); height: 14; radius: 7; color: Theme.red
    border.width: 2; border.color: Qt.rgba(17/255, 17/255, 27/255, .6)
    M { id: bt; anchors.centerIn: parent; text: root.badge; font.pixelSize: 9; font.weight: Font.Bold; color: Theme.crust }
  }
  MouseArea {
    id: ma
    anchors.fill: parent; hoverEnabled: true
    onClicked: { if (root.panel !== "") Sys.openPanel(root.panel, root); root.clicked() }
    onWheel: w => root.wheeled(w.angleDelta.y)
    onEntered: if (root.menuLike && root.panel !== "" && Sys.panel !== root.panel && (Sys.panel === "arch" || Sys.panel.indexOf("menu:") === 0)) Sys.openPanel(root.panel, root)
  }
}
