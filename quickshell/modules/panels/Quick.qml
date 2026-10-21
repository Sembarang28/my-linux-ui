import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 360
  readonly property var player: Mpris.players.values.find(p => p.isPlaying) || Mpris.players.values[0] || null

  component Tile: Rectangle {
    property string icon; property string label; property string sub; property bool isOn: false
    signal clicked()
    width: (parent.width - 8) / 2; height: 52; radius: 12
    color: isOn ? Theme.accentSoft : (tm.containsMouse ? Theme.surface0 : Theme.card60)
    border.width: 1; border.color: isOn ? Theme.accentA(.35) : Theme.hairline
    Rectangle { x: 11; anchors.verticalCenter: parent.verticalCenter; width: 30; height: 30; radius: 15; color: isOn ? Theme.accent : Theme.surface1
      Icon { anchors.centerIn: parent; name: icon; size: 15; color: isOn ? Theme.crust : Theme.subtext1 } }
    Column { x: 51; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 58
      T { text: label; font.pixelSize: 12; font.weight: Font.DemiBold }
      T { text: sub; font.pixelSize: 11; color: isOn ? Theme.subtext0 : Theme.overlay1; width: parent.width; elide: Text.ElideRight } }
    MouseArea { id: tm; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
  }
  component Round: Rectangle {
    property string icon; property bool danger: false
    signal clicked()
    width: 32; height: 32; radius: 16
    color: rm.containsMouse ? (danger ? Theme.red : Theme.surface1) : Theme.surface0
    Icon { anchors.centerIn: parent; name: icon; size: 15; color: rm.containsMouse && danger ? Theme.crust : (rm.containsMouse ? Theme.text : Theme.subtext1) }
    MouseArea { id: rm; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
  }

  Column {
    width: parent.width
    Item {
      width: parent.width; height: 36
      Rectangle { id: av; width: 36; height: 36; radius: 18
        gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: Theme.accent } GradientStop { position: 1; color: Theme.blue } }
        T { anchors.centerIn: parent; text: Sys.initials; font.weight: Font.Bold; color: Theme.crust } }
      Column { x: 46; anchors.verticalCenter: parent.verticalCenter
        T { text: Sys.fullName; font.weight: Font.DemiBold }
        M { text: "up " + Sys.uptime; font.pixelSize: 11; color: Theme.overlay1 } }
      Row { anchors { right: parent.right; verticalCenter: parent.verticalCenter } spacing: 4
        Round { icon: "scan"; onClicked: { Sys.close(); Sys.niriAction(["screenshot"]) } }
        Round { icon: "gear"; onClicked: Sys.doAction("settings") }
        Round { icon: "lock"; onClicked: Sys.doAction("lock") }
        Round { icon: "power"; danger: true; onClicked: Sys.doAction("shutdown") } }
    }
    Item { width: 1; height: 12 }
    Grid {
      columns: 2; spacing: 8; width: parent.width
      Tile { icon: Sys.wifi ? "wifi" : "wifiOff"; label: "Wi-Fi"; sub: Sys.wifi ? (Sys.wifiName || "On") : "Off"; isOn: Sys.wifi; onClicked: Sys.toggleWifi() }
      Tile { icon: "bluetooth"; label: "Bluetooth"; sub: Sys.bt ? "On" : "Off"; isOn: Sys.bt; onClicked: Sys.toggleBt() }
      Tile { icon: "moon"; label: "Night Light"; sub: Prefs.night ? Prefs.nightTemp + "K" : "Off"; isOn: Prefs.night; onClicked: Prefs.toggle("night") }
      Tile { icon: "bell"; label: "Do Not Disturb"; sub: Prefs.dnd ? "On" : "Off"; isOn: Prefs.dnd; onClicked: Prefs.toggle("dnd") }
      Tile { icon: "gauge"; label: "Power Mode"; sub: Sys.profileLabel; isOn: true; onClicked: Sys.cycleProfile() }
      Tile { icon: "coffee"; label: "Caffeine"; sub: Prefs.caffeine ? "Idle inhibited" : "Off"; isOn: Prefs.caffeine; onClicked: Prefs.toggle("caffeine") }
    }
    Item { width: 1; height: 12 }
    Rectangle {
      width: parent.width; height: sl.implicitHeight + 16; radius: 12; color: Qt.rgba(49/255, 50/255, 68/255, .4)
      Column { id: sl; x: 10; y: 8; width: parent.width - 20; spacing: 4
        SliderRow { width: parent.width; icon: "volume"; value: Sys.volume; onMoved: v => Sys.setVolume(v) }
        SliderRow { width: parent.width; icon: "sun"; value: Sys.brightness; onMoved: v => Sys.setBrightness(v) }
        SliderRow { width: parent.width; icon: "mic"; value: Sys.mic; onMoved: v => Sys.setMic(v) } }
    }
    Item { width: 1; height: 12 }
    Rectangle {
      width: parent.width; height: 68; radius: 12; border.width: 1; border.color: Theme.hairline
      gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: Qt.rgba(203/255, 166/255, 247/255, .14) } GradientStop { position: 1; color: Qt.rgba(137/255, 180/255, 250/255, .08) } }
      Rectangle { id: cover; x: 10; anchors.verticalCenter: parent.verticalCenter; width: 46; height: 46; radius: 9; clip: true
        gradient: Gradient { GradientStop { position: 0; color: Theme.peach } GradientStop { position: .5; color: Theme.pink } GradientStop { position: 1; color: Theme.mauve } }
        Image { anchors.fill: parent; source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""; fillMode: Image.PreserveAspectCrop; visible: status === Image.Ready } }
      Column { x: 68; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 68 - 110
        T { text: root.player ? (root.player.trackTitle || "Unknown") : "Nothing playing"; font.weight: Font.DemiBold; width: parent.width; elide: Text.ElideRight }
        T { text: root.player ? (root.player.trackArtist + (root.player.trackAlbum ? " · " + root.player.trackAlbum : "")) : "No media player"; font.pixelSize: 11; color: Theme.overlay1; width: parent.width; elide: Text.ElideRight }
        Item { width: parent.width; height: 9
          Rectangle { y: 6; width: parent.width; height: 3; radius: 2; color: Theme.surface1
            Rectangle { width: root.player && root.player.length > 0 ? parent.width * Math.min(1, root.player.position / root.player.length) : 0; height: 3; radius: 2; color: Theme.accent } } } }
      Row { anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter } spacing: 2
        Repeater {
          model: [["prev", 13], ["play", 14], ["next", 13]]
          Rectangle { required property var modelData; width: 28; height: 28; radius: 14; color: mm.containsMouse ? Theme.surface0 : "transparent"
            Icon { anchors.centerIn: parent; size: modelData[1]; color: mm.containsMouse ? Theme.text : Theme.subtext1
              name: modelData[0] === "play" ? (root.player && root.player.isPlaying ? "pause" : "play") : modelData[0] }
            MouseArea { id: mm; anchors.fill: parent; hoverEnabled: true
              onClicked: { if (!root.player) return; if (modelData[0] === "prev") root.player.previous(); else if (modelData[0] === "next") root.player.next(); else root.player.togglePlaying() } } }
        } }
    }
  }
  Timer { interval: 1000; running: root.player && root.player.isPlaying; repeat: true; onTriggered: if (root.player) root.player.positionChanged() }
}
