import Quickshell
import QtQuick
import "../services"
import "../components"

FloatingWindow {
  id: win
  title: "About This PC"
  visible: Sys.aboutOpen
  color: "transparent"
  implicitWidth: 470; implicitHeight: col.implicitHeight + 40 + 22
  onVisibleChanged: { if (visible) Sys.loadSpecs(); else Sys.aboutOpen = false }

  WinFrame {
    anchors.fill: parent; titlebar: true; onCloseRequested: Sys.aboutOpen = false
    Column {
      id: col
      y: 40; width: parent.width - 56; x: 28; spacing: 0
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 110; height: 110; radius: 28
        color: Qt.rgba(137/255, 180/255, 250/255, .10); border.width: 1; border.color: Qt.rgba(137/255, 180/255, 250/255, .18)
        Icon { anchors.centerIn: parent; name: "arch"; size: 64; color: Theme.blue } }
      Item { width: 1; height: 16 }
      T { anchors.horizontalCenter: parent.horizontalCenter; text: (Sys.specs.find(s => s[0] === "OS") || ["", "Arch Linux"])[1].replace(/ x86_64/, "").replace(/ aarch64/, ""); font.pixelSize: 26; font.weight: Font.ExtraBold; font.letterSpacing: -0.8 }
      T { anchors.horizontalCenter: parent.horizontalCenter; text: "Rolling release · x86_64 · " + Sys.user + "@" + Sys.hostName; color: Theme.overlay1; font.pixelSize: 12 }
      Item { width: 1; height: 18 }
      Grid {
        columns: 2; columnSpacing: 14; rowSpacing: 5; width: parent.width
        Repeater {
          model: Sys.specs.reduce((a, r) => a.concat([r[0], r[1]]), [])
          Text {
            required property string modelData; required property int index
            readonly property bool key: index % 2 === 0
            width: key ? 110 : parent.width - 124
            text: modelData; elide: Text.ElideRight
            horizontalAlignment: key ? Text.AlignRight : Text.AlignLeft
            font.family: key ? Theme.ui : Theme.mono; font.pixelSize: key ? 12 : 12; font.weight: key ? Font.DemiBold : Font.Normal
            color: key ? Theme.subtext0 : Theme.text
          }
        }
      }
      Item { width: 1; height: 16 }
      Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 5
        Repeater { model: ["surface", "red", "green", "yellow", "blue", "mauve", "teal", "rosewater"]
          Rectangle { required property string modelData; width: 18; height: 18; radius: 5; color: Theme.c(modelData) } } }
      Item { width: 1; height: 18 }
      Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
        Btn { text: "More Info…"; onClicked: { Sys.aboutOpen = false; Sys.openSettings("general") } }
        Btn { text: "Copy fastfetch"; kind: "primary"; onClicked: Quickshell.execDetached(["sh", "-c", "fastfetch --pipe 2>/dev/null | wl-copy"]) } }
      Item { width: 1; height: 14 }
      T { width: parent.width; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 11; color: Theme.overlay0; lineHeight: 1.4
          text: "Arch Linux is a trademark of Levente Polyak.\nCatppuccin Mocha · Quickshell · niri" }
    }
  }
}
