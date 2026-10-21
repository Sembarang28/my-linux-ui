import Quickshell
import QtQuick
import "../services"

// Glass window body with macOS traffic lights (used inside FloatingWindow)
Rectangle {
  id: root
  property string title: ""
  property bool titlebar: true
  property bool focused: true
  default property alias content: body.data
  readonly property alias bodyItem: body
  signal closeRequested()
  signal maxRequested()
  color: Theme.glassWin
  border.width: 1; border.color: Theme.hairline2

  component Light: Rectangle {
    property color tone; property string glyph: ""
    signal clicked()
    width: 12; height: 12; radius: 6; color: root.focused ? tone : Theme.surface1
    Icon { anchors.centerIn: parent; name: glyph; size: 8; color: Qt.rgba(17/255, 17/255, 27/255, .7); opacity: lm.containsMouse ? 1 : 0; visible: glyph !== "" }
    MouseArea { id: lm; anchors.fill: parent; anchors.margins: -3; hoverEnabled: true; onClicked: parent.clicked() }
  }
  Row {
    visible: root.titlebar
    x: 14; y: 14; spacing: 8; z: 5
    Light { tone: Theme.red; glyph: "x"; onClicked: root.closeRequested() }
    Light { tone: Theme.yellow }
    Light { tone: Theme.green; glyph: "arrows"; onClicked: root.maxRequested() }
  }
  Item {
    id: tb; visible: root.titlebar && root.title !== ""
    width: parent.width; height: 40
    T { anchors.centerIn: parent; text: root.title; font.weight: Font.DemiBold; color: Theme.subtext0; font.pixelSize: 12 }
  }
  Item { id: body; anchors.fill: parent }
}
