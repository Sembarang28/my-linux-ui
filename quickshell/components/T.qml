import QtQuick
import "../services"

// Default UI text (Quicksand 13/500, --text)
Text {
  color: Theme.text
  font.family: Theme.ui
  font.pixelSize: 13
  font.weight: Font.Medium
  renderType: Text.NativeRendering
  elide: Text.ElideNone
}
