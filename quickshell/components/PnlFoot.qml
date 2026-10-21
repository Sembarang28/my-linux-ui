import QtQuick
import "../services"

// .pnl-foot: top hairline + row of link buttons
Item {
  default property alias content: row.data
  width: parent ? parent.width : 300
  height: 12 + 1 + 10 + 28
  Rectangle { y: 12; width: parent.width; height: 1; color: Theme.hairline2 }
  Row { id: row; y: 12 + 1 + 10; spacing: 8 }
}
