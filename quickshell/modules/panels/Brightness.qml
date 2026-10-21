import QtQuick
import "../../services"
import "../../components"

PanelBox {
  implicitWidth: 320
  Column {
    width: parent.width
    PnlHead { icon: "sun"; iconColor: Theme.yellow; title: "Display"; meta: "DDC/CI" }
    Item { width: 1; height: 12 }
    SliderRow { width: parent.width; icon: "sun"; value: Sys.brightness; onMoved: v => Sys.setBrightness(v) }
    PnlSec { text: "Night Light" }
    Li { icon: "moon"; title: "Night Light"; sub: "Sunset to sunrise · wlsunset"; on: Prefs.night
         Sw { on: Prefs.night; onToggled: Prefs.toggle("night") } onClicked: Prefs.toggle("night") }
    Item { width: 1; height: 6 }
    SliderRow { width: parent.width; icon: "thermo"; value: Prefs.nightTemp; min: 2500; max: 6500; unit: "K"; valueWidth: 46; onMoved: v => Prefs.set("nightTemp", v) }
    PnlFoot { LinkBtn { text: "Display Settings…"; onClicked: Sys.doAction("settings:displays") } }
  }
}
