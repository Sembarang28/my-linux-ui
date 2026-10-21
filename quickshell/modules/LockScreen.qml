import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import "../services"
import "../components"

// ext-session-lock lock screen (blurred wallpaper, big mono clock, PAM password)
WlSessionLock {
  id: lock
  locked: Sys.locked

  PamContext {
    id: pam
    user: Sys.user
    configDirectory: Quickshell.shellPath("pam")
    config: "password.conf"
    onResponseRequiredChanged: if (responseRequired && pass.length) respond(pass)
    onCompleted: r => { if (r === PamResult.Success) { Sys.locked = false } else { fail = true; pass = "" } }
  }
  property string pass: ""
  property bool fail: false

  WlSessionLockSurface {
    color: Theme.crust
    SystemClock { id: clk; precision: SystemClock.Minutes }
    Image { anchors.fill: parent; source: Prefs.wall === "unix" ? Qt.resolvedUrl("../assets/unix.jpg") : ""; fillMode: Image.PreserveAspectCrop; opacity: 0.35 }
    Rectangle { anchors.fill: parent; color: Qt.rgba(17/255, 17/255, 27/255, .55) }
    Column {
      anchors.horizontalCenter: parent.horizontalCenter; y: parent.height * 0.12; spacing: 6
      T { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(clk.date, "dddd, MMM dd, yyyy"); font.pixelSize: 18; font.weight: Font.DemiBold; color: Theme.subtext1 }
      M { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(clk.date, "HH:mm"); font.pixelSize: 112; font.weight: Font.Bold; font.letterSpacing: -4.5 }
    }
    Column {
      anchors.horizontalCenter: parent.horizontalCenter; y: parent.height - height - parent.height * 0.14; spacing: 12
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 64; height: 64; radius: 32
        gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: Theme.accent } GradientStop { position: 1; color: Theme.blue } }
        T { anchors.centerIn: parent; text: Sys.initials; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.crust } }
      T { anchors.horizontalCenter: parent.horizontalCenter; text: Sys.fullName; font.pixelSize: 15 }
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 220; height: 34; radius: 17; color: Qt.rgba(49/255, 50/255, 68/255, .7); border.width: 1; border.color: lock.fail ? Theme.red : Theme.hairline2
        TextInput { id: pw; anchors { fill: parent; leftMargin: 14; rightMargin: 36 } verticalAlignment: TextInput.AlignVCenter; echoMode: TextInput.Password
          color: Theme.text; font.family: Theme.ui; font.pixelSize: 13; focus: true; passwordCharacter: "•"
          onTextChanged: lock.pass = text
          onAccepted: { lock.fail = false; pam.start() }
          Connections { target: lock; function onFailChanged() { if (lock.fail) pw.text = "" } }
          T { visible: !pw.text; anchors.verticalCenter: parent.verticalCenter; text: "Enter Password"; color: Theme.overlay1 } }
        Rectangle { anchors { right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter } width: 24; height: 24; radius: 12; color: Theme.accent
          Icon { anchors.centerIn: parent; name: "chevR"; size: 14; color: Theme.crust }
          MouseArea { anchors.fill: parent; onClicked: { lock.fail = false; pam.start() } } } }
      T { anchors.horizontalCenter: parent.horizontalCenter; text: lock.fail ? "Wrong password, try again" : "Press Enter to unlock"; font.pixelSize: 11; color: lock.fail ? Theme.red : Theme.overlay1 }
    }
  }
}
