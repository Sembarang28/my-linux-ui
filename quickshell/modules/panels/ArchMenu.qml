import QtQuick
import "../../services"
import "../../components"

// Arch menu (ARCH_MENU) with the "Recent Items" submenu
PanelBox {
  id: root
  pad: 5
  implicitWidth: 240
  property bool subOpen: false

  Column {
    width: parent.width
    MenuItem { label: "About This PC"; icon: "info"; onClicked: Sys.doAction("about"); onEntered: root.subOpen = false }
    MenuSep {}
    MenuItem { label: "System Settings…"; icon: "gear"; kbd: "Super S"; onClicked: Sys.doAction("settings"); onEntered: root.subOpen = false }
    MenuItem { label: "Package Updates…"; icon: "package"; onClicked: Sys.doAction("settings:general"); onEntered: root.subOpen = false }
    MenuSep {}
    MenuItem { id: recent; label: "Recent Items"; icon: "clock"; hasSub: true; open: root.subOpen; onEntered: root.subOpen = true }
    MenuSep {}
    MenuItem { label: "Force Quit " + Sys.focusedApp; icon: "zap"; kbd: "Super ⇧ Q"; onClicked: Sys.doAction("forcequit"); onEntered: root.subOpen = false }
    MenuSep {}
    MenuItem { label: "Sleep"; icon: "moon"; onClicked: { Sys.close(); Quickshell.execDetached(["systemctl", "suspend"]) } onEntered: root.subOpen = false }
    MenuItem { label: "Restart…"; icon: "restart"; onClicked: Sys.doAction("restart"); onEntered: root.subOpen = false }
    MenuItem { label: "Shut Down…"; icon: "power"; onClicked: Sys.doAction("shutdown"); onEntered: root.subOpen = false }
    MenuSep {}
    MenuItem { label: "Lock Screen"; icon: "lock"; kbd: "Super Alt L"; onClicked: Sys.doAction("lock"); onEntered: root.subOpen = false }
    MenuItem { label: "Log Out " + Sys.fullName + "…"; icon: "logout"; kbd: "Super ⇧ E"; onClicked: Sys.doAction("logout"); onEntered: root.subOpen = false }
  }

  // submenu
  PanelBox {
    visible: root.subOpen
    x: root.width + 6; y: recent.mapToItem(root, 0, 0).y - 5
    pad: 5; implicitWidth: 240
    Column {
      width: parent.width
      MenuItem { label: "APPLICATIONS"; disabled: true; height: 26 }
      Repeater {
        model: [["Ghostty", "terminal", "ghostty"], ["Zen Browser", "globe", "zen-browser"], ["Code - OSS", "file", "code"], ["Spotify", "headphones", "spotify"]]
        MenuItem { required property var modelData; label: modelData[0]; icon: modelData[1]
                   onClicked: { Sys.close(); Quickshell.execDetached(["gtk-launch", modelData[2]]) } }
      }
      MenuSep {}
      MenuItem { label: "DOCUMENTS"; disabled: true }
      Repeater {
        model: ["niri/config.kdl", "quickshell/shell.qml", "fish/config.fish"]
        MenuItem { required property string modelData; label: modelData; icon: "file"
                   onClicked: { Sys.close(); Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/.config/" + modelData]) } }
      }
    }
  }
}
