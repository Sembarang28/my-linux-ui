import Quickshell.Bluetooth
import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 340
  readonly property var adapter: Bluetooth.defaultAdapter
  Column {
    width: parent.width
    PnlHead { icon: "bluetooth"; iconColor: Theme.blue; title: "Bluetooth"; Sw { on: Sys.bt; onToggled: Sys.toggleBt() } }
    Item { width: 1; height: 12 }
    Column {
      visible: Sys.bt; width: parent.width
      PnlSec { text: "Devices"; gap: 0 }
      Repeater {
        model: root.adapter ? root.adapter.devices : null
        Li {
          required property var modelData
          icon: modelData.icon === "input-mouse" ? "mouse" : modelData.icon === "input-keyboard" ? "keyboard" : modelData.icon === "input-gaming" ? "gamepad" : modelData.icon === "phone" ? "phone" : "headphones"
          title: modelData.name || modelData.address
          sub: modelData.connected ? "Connected" + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "") : (modelData.paired ? "Not Connected" : "Available")
          on: modelData.connected
          onClicked: { if (modelData.connected) modelData.disconnect(); else if (modelData.paired) modelData.connect(); else modelData.pair() }
        }
      }
    }
    Li { visible: !Sys.bt; icon: "bluetooth"; title: "Bluetooth is off"; sub: "bluetoothd idle" }
    PnlFoot { LinkBtn { text: "Bluetooth Settings…"; onClicked: Sys.doAction("settings:bluetooth") } }
  }
}
