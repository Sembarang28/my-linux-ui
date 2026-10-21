import QtQuick
import "../services"

// .tile-ic: coloured rounded square with a glyph (settings rows, lists)
Rectangle {
  id: root
  property string icon: ""
  property string tone: "overlay"      // palette name or colour
  property int box: 30
  property int glyph: 16
  width: box; height: box; radius: box >= 60 ? 18 : (box >= 28 ? 8 : 6)
  color: Theme.c(tone)
  Icon { anchors.centerIn: parent; name: root.icon; size: root.glyph; color: Theme.crust }
}
