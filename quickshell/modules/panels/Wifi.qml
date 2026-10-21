import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 340
  property string asking: ""
  Component.onCompleted: Net.refresh()
  Column {
    width: parent.width
    PnlHead { icon: "wifi"; iconColor: Theme.blue; title: "Wi-Fi"; Sw { on: Sys.wifi; onToggled: Sys.toggleWifi() } }
    Item { width: 1; height: 12 }
    Column {
      visible: Sys.wifi; width: parent.width
      Li { icon: "wifi"; on: true; title: Sys.wifiName || "Not connected"; sub: Sys.wifiName ? "Connected" : ""; monoSub: true
           Icon { name: "lock"; size: 12; color: Theme.overlay1 } Icon { name: "check"; size: 14; color: Theme.overlay1 } }
      PnlSec { text: "Other Networks" }
      T { visible: Net.status !== ""; text: Net.status; color: Theme.peach; font.pixelSize: 11; bottomPadding: 6 }
      Repeater {
        model: Net.networks.filter(n => !n.active).slice(0, 8)
        Column {
          required property var modelData
          width: parent.width
          Li { icon: "wifi"; title: modelData.ssid; onClicked: { if (modelData.secure && !modelData.saved) root.asking = (root.asking === modelData.ssid ? "" : modelData.ssid); else Net.connectTo(modelData.ssid, "") }
               Icon { visible: modelData.secure; name: "lock"; size: 12; color: Theme.overlay1 }
               M { text: "▂▄▆█".slice(0, Math.max(1, Math.min(4, Math.ceil(modelData.signal / 25)))); color: Theme.overlay1; font.pixelSize: 11 } }
          Rectangle { visible: root.asking === modelData.ssid; width: parent.width - 16; x: 8; height: 32; radius: 8; color: Theme.surface0
            TextInput { id: pw; anchors { fill: parent; leftMargin: 10; rightMargin: 10 } verticalAlignment: TextInput.AlignVCenter; echoMode: TextInput.Password
              color: Theme.text; font.family: Theme.ui; font.pixelSize: 13; focus: visible; clip: true
              onAccepted: { Net.connectTo(modelData.ssid, text); root.asking = "" } 
              T { visible: !pw.text; anchors.verticalCenter: parent.verticalCenter; text: "Password…  (Enter)"; color: Theme.overlay1 } } }
        }
      }
    }
    Li { visible: !Sys.wifi; icon: "wifiOff"; title: "Wi-Fi is off"; sub: "Turn on to see networks" }
    PnlFoot { LinkBtn { text: "Wi-Fi Settings…"; onClicked: Sys.doAction("settings:wifi") } }
  }
}
