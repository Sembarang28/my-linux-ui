import QtQuick
import "../services"

// .pnl-sec section label (14px above, 6px below)
Item {
  property alias text: t.text
  property int gap: 14
  width: parent ? parent.width : 300
  height: gap + 17 + 6
  T { id: t; x: 2; y: parent.gap; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.overlay1; font.capitalization: Font.AllUppercase; font.letterSpacing: 0.66 }
}
