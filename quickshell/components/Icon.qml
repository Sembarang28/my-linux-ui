import QtQuick
import QtQuick.Effects
import "../services"

// Lucide-style icon from assets/icons (extracted from mocha-shell.html), recoloured with `color`
Item {
  id: root
  property string name: ""
  property int size: 16
  property color color: Theme.text
  property url url: ""
  implicitWidth: size; implicitHeight: size
  width: size; height: size

  Image {
    id: img
    anchors.fill: parent
    source: root.url != "" ? root.url : (root.name !== "" ? Qt.resolvedUrl("../assets/icons/" + root.name + ".svg") : "")
    sourceSize: Qt.size(root.size * 3, root.size * 3)
    smooth: true; mipmap: true
    fillMode: Image.PreserveAspectFit
    layer.enabled: root.url == ""
    layer.effect: MultiEffect { colorization: 1.0; colorizationColor: root.color; brightness: 1.0 }
  }
}
