import Quickshell
import QtQuick
import "../services"
import "../components"

// System Settings (full-size tiled window under the bar, like `.settings.max` in the HTML)
FloatingWindow {
  id: win
  title: "System Settings"
  visible: Sys.settingsOpen
  color: "transparent"
  implicitWidth: 920; implicitHeight: 640
  onVisibleChanged: { if (visible) { hist = []; fwd = []; Sys.loadSpecs() } else Sys.settingsOpen = false }

  property var hist: []
  property var fwd: []
  property string filter: ""
  readonly property string pane: Sys.settingsPane
  readonly property string sub: Sys.settingsSub
  function go(p, s) { hist = hist.concat([[pane, sub]]); fwd = []; Sys.settingsPane = p; Sys.settingsSub = s || ""; mainFlick.contentY = 0 }
  function back() { if (!hist.length) return; var h = hist.slice(), l = h.pop(); fwd = fwd.concat([[pane, sub]]); hist = h; Sys.settingsPane = l[0]; Sys.settingsSub = l[1] }
  function forward() { if (!fwd.length) return; var f = fwd.slice(), l = f.pop(); hist = hist.concat([[pane, sub]]); fwd = f; Sys.settingsPane = l[0]; Sys.settingsSub = l[1] }

  function res(s) {
    return String(s).replace("@wifiName", Sys.wifiName || "Not connected").replace("@profile", Sys.profileLabel).replace("@host", Sys.hostName)
      .replace("@fullName", Sys.fullName).replace("@userline", Sys.user + " · wheel, video, input").replace("@uptime", Sys.uptime)
      .replace("@disk", Math.round(Sys.diskUsed) + " of " + Math.round(Sys.diskTotal) + " GB")
  }
  function getBool(k) { return k === "wifi" ? Sys.wifi : k === "bt" ? Sys.bt : !!Prefs[k] }
  function flip(k) { if (k === "wifi") Sys.toggleWifi(); else if (k === "bt") Sys.toggleBt(); else Prefs.toggle(k) }
  function getNum(k) { return k === "vol" ? Sys.volume : k === "mic" ? Sys.mic : Sys.brightness }
  function setNum(k, v) { if (k === "vol") Sys.setVolume(v); else if (k === "mic") Sys.setMic(v); else Sys.setBrightness(v) }

  // ---------- building blocks ----------
  component Group: Rectangle {
    default property alias rows: col.data
    width: parent ? parent.width : 400; height: col.height; radius: 12; color: Theme.card35; border.width: 1; border.color: Theme.hairline2; clip: true
    Column { id: col; width: parent.width }
  }
  component SRow: Item {
    id: row
    property var r: ({})
    property bool first: true
    property bool noIcon: !r.ic
    width: parent ? parent.width : 400
    height: Math.max(48, txt.implicitHeight + 16)
    readonly property bool linkish: r.k === "nav" || (r.k === "select" && r.l === "Power Mode")
    Rectangle { visible: !row.first; x: row.noIcon ? 14 : 56; width: parent.width - x - 14; height: 1; color: Theme.hairline2 }
    Rectangle { anchors.fill: parent; color: rm.containsMouse && row.linkish ? Theme.hover5 : "transparent" }
    TileIc { visible: !!r.ic; x: 14; anchors.verticalCenter: parent.verticalCenter; box: 30; glyph: 16; icon: r.ic || ""; tone: r.c || "overlay" }
    Column {
      id: txt; x: row.noIcon ? 14 : 56; anchors.verticalCenter: parent.verticalCenter; width: parent.width - x - rightBox.width - 28
      T { text: win.res(r.l); font.pixelSize: 13; width: parent.width; elide: Text.ElideRight }
      T { visible: !!r.s; text: win.res(r.s || ""); font.pixelSize: 11; color: Theme.overlay1; width: parent.width; elide: Text.ElideRight }
    }
    Row {
      id: rightBox; anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } spacing: 8
      Sw { visible: r.k === "toggle"; on: r.k === "toggle" && win.getBool(r.key); onToggled: win.flip(r.key) }
      T { visible: r.k === "nav" && !!r.v; text: win.res(r.v || ""); color: Theme.overlay1; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
      Icon { visible: r.k === "nav"; name: "chevR"; size: 14; color: Theme.overlay0; anchors.verticalCenter: parent.verticalCenter }
      M { visible: r.k === "value"; text: win.res(r.v || ""); color: Theme.overlay1; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
      Rectangle { visible: r.k === "select"; height: 26; width: sl.implicitWidth + 28; radius: 7; color: Theme.surface0; border.width: 1; border.color: Theme.hairline2
        Row { anchors.centerIn: parent; spacing: 6
          T { id: sl; text: win.res(r.v || ""); font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
          Icon { name: "chevD"; size: 12; color: Theme.overlay1; anchors.verticalCenter: parent.verticalCenter } } }
      Row { visible: r.k === "range"; spacing: 8
        Slide { width: 220; value: r.k === "range" ? win.getNum(r.key) : 0; onMoved: v => win.setNum(r.key, v); anchors.verticalCenter: parent.verticalCenter }
        M { width: 36; horizontalAlignment: Text.AlignRight; text: (r.k === "range" ? win.getNum(r.key) : 0) + "%"; font.pixelSize: 12; color: Theme.overlay1; anchors.verticalCenter: parent.verticalCenter } }
    }
    MouseArea { id: rm; anchors.fill: parent; hoverEnabled: true; z: -1
      onClicked: { if (r.k === "nav" && r.to) win.go(win.pane, r.to); else if (r.k === "select" && r.l === "Power Mode") Sys.cycleProfile() } }
  }
  component Hero: Rectangle {
    property string icon; property string tone; property string name; property string desc: ""
    property bool arch: false
    width: parent ? parent.width : 400; height: hc.implicitHeight + 48; radius: 14; color: Theme.card35; border.width: 1; border.color: Theme.hairline2
    Column { id: hc; y: 26; width: parent.width - 64; x: 32; spacing: 12
      TileIc { anchors.horizontalCenter: parent.horizontalCenter; box: 72; glyph: 38; icon: parent.parent.icon; tone: parent.parent.tone }
      T { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.name; font.pixelSize: 24; font.weight: Font.ExtraBold; font.letterSpacing: -0.5 }
      T { visible: parent.parent.desc !== ""; width: Math.min(480, parent.width); anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.desc
          color: Theme.subtext0; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; lineHeight: 1.3 } }
  }

  WinFrame {
    anchors.fill: parent; titlebar: true; onCloseRequested: Sys.settingsOpen = false; onMaxRequested: Sys.niriAction(["maximize-column"])
    Row {
      anchors.fill: parent
      // ---------------- sidebar ----------------
      Rectangle {
        width: 260; height: parent.height; color: Qt.rgba(17/255, 17/255, 27/255, .32)
        Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.hairline }
        Rectangle { x: 12; y: 44; width: parent.width - 24; height: 30; radius: 8; color: Theme.surface0; border.width: 1; border.color: si.activeFocus ? Theme.accent : "transparent"
          Icon { x: 9; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 14; color: Theme.overlay1 }
          TextInput { id: si; anchors { fill: parent; leftMargin: 30; rightMargin: 9 } verticalAlignment: TextInput.AlignVCenter; color: Theme.text; font.family: Theme.ui; font.pixelSize: 13; clip: true
            onTextChanged: win.filter = text.toLowerCase()
            T { visible: !si.text; anchors.verticalCenter: parent.verticalCenter; text: "Search"; color: Theme.overlay1 } } }
        Flickable {
          y: 84; width: parent.width; height: parent.height - 84; contentHeight: navCol.height + 14; clip: true; boundsBehavior: Flickable.StopAtBounds
          Column { id: navCol; x: 10; width: parent.width - 20; spacing: 0
            Rectangle { width: parent.width; height: 58; radius: 10; color: am.containsMouse ? Theme.hover5 : "transparent"
              Rectangle { x: 8; anchors.verticalCenter: parent.verticalCenter; width: 42; height: 42; radius: 21
                gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: Theme.accent } GradientStop { position: 1; color: Theme.blue } }
                T { anchors.centerIn: parent; text: Sys.initials; font.pixelSize: 15; font.weight: Font.Bold; color: Theme.crust } }
              Column { x: 60; anchors.verticalCenter: parent.verticalCenter
                T { text: Sys.fullName; font.pixelSize: 14; font.weight: Font.DemiBold }
                T { text: "Local Account · wheel"; font.pixelSize: 11; color: Theme.overlay1 } }
              MouseArea { id: am; anchors.fill: parent; hoverEnabled: true; onClicked: win.go("users") } }
            Item { width: 1; height: 10 }
            Repeater {
              model: SettingsData.navGroups
              Column {
                required property var modelData
                width: navCol.width
                readonly property var items: modelData.filter(n => n[1].toLowerCase().indexOf(win.filter) >= 0)
                visible: items.length > 0
                Repeater {
                  model: parent.items
                  Rectangle {
                    required property var modelData
                    readonly property bool act: modelData[0] === win.pane
                    width: navCol.width; height: 30; radius: 7
                    color: act ? Theme.accent : (nm.containsMouse ? Theme.hover5 : "transparent")
                    TileIc { x: 8; anchors.verticalCenter: parent.verticalCenter; box: 22; glyph: 13; icon: modelData[2]; tone: modelData[3] }
                    T { x: 39; anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; color: act ? Theme.crust : Theme.text; font.weight: act ? Font.DemiBold : Font.Medium }
                    MouseArea { id: nm; anchors.fill: parent; hoverEnabled: true; onClicked: win.go(modelData[0]) } }
                }
                Item { width: 1; height: 12 }
              }
            }
          }
        }
      }
      // ---------------- main ----------------
      Item {
        width: parent.width - 260; height: parent.height
        Flickable {
          id: mainFlick
          anchors.fill: parent; contentHeight: content.height + 82; clip: true; boundsBehavior: Flickable.StopAtBounds
          Column {
            id: content
            y: 52 + 0; width: Math.min(900, parent.width - 56); x: (parent.width - width) / 2; spacing: 14
            Loader { width: parent.width; sourceComponent: win.sub !== "" ? subView : paneView }
          }
        }
        // sticky top bar
        Rectangle { width: parent.width; height: 52; color: Qt.rgba(30/255, 30/255, 46/255, .55)
          Row { x: 20; anchors.verticalCenter: parent.verticalCenter; spacing: 4
            Repeater { model: [["chevL", "back"], ["chevR", "fwd"]]
              Rectangle { required property var modelData
                readonly property bool en: modelData[1] === "back" ? win.hist.length > 0 : win.fwd.length > 0
                width: 28; height: 28; radius: 7; color: bm.containsMouse && en ? Theme.surface0 : "transparent"
                Icon { anchors.centerIn: parent; name: modelData[0]; size: 18; color: parent.en ? Theme.subtext0 : Theme.surface2 }
                MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; onClicked: modelData[1] === "back" ? win.back() : win.forward() } } }
            T { leftPadding: 8; text: win.sub !== "" ? "About" : SettingsData.meta(win.pane).label; font.pixelSize: 14; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter } } }
      }
    }
  }

  // ---------------- views ----------------
  Component {
    id: subView
    Column {
      spacing: 14
      Rectangle { width: parent.width; height: 24 + 84 + 20 + 40 + 20; radius: 14; color: Theme.card35; border.width: 1; border.color: Theme.hairline2
        Column { y: 24; width: parent.width; spacing: 6
          Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 84; height: 84; radius: 22; color: Qt.rgba(137/255, 180/255, 250/255, .10); border.width: 1; border.color: Qt.rgba(137/255, 180/255, 250/255, .18)
            Icon { anchors.centerIn: parent; name: "arch"; size: 48; color: Theme.blue } }
          T { anchors.horizontalCenter: parent.horizontalCenter; text: "Arch Linux"; font.pixelSize: 24; font.weight: Font.ExtraBold; topPadding: 6 }
          M { anchors.horizontalCenter: parent.horizontalCenter; text: Sys.user + "@" + Sys.hostName + " · rolling"; font.pixelSize: 12; color: Theme.subtext0 } } }
      Group { Repeater { model: Sys.specs; SRow { required property var modelData; required property int index; first: index === 0; r: ({ k: "value", l: modelData[0], v: modelData[1] }) } } }
    }
  }
  Component {
    id: paneView
    Column {
      spacing: 14
      readonly property var def: SettingsData.panes[win.pane] || { desc: "", groups: [] }
      readonly property var m: SettingsData.meta(win.pane)
      Hero { icon: m.ic; tone: m.c; name: m.label; desc: def.desc || "" }
      Loader { width: parent.width; sourceComponent: def.custom === "appearance" ? appearance : def.custom === "displays" ? displays : def.custom === "wallpaper" ? wallpaper : groups }
    }
  }
  Component {
    id: groups
    Column {
      spacing: 14
      Repeater {
        model: SettingsData.panes[win.pane].groups
        Column {
          id: gcol
          required property var modelData
          width: parent.width; spacing: 8
          readonly property bool isObj: modelData.rows !== undefined
          readonly property var rows: isObj ? modelData.rows : modelData
          T { visible: gcol.isObj; text: gcol.isObj ? modelData.title : ""; font.pixelSize: 12; font.weight: Font.Bold; color: Theme.subtext0; leftPadding: 4 }
          Group { Repeater { model: gcol.rows; SRow { required property var modelData; required property int index; first: index === 0; r: modelData } } }
        }
      }
    }
  }
  Component {
    id: appearance
    Column {
      spacing: 14
      Group {
        Grid { columns: 4; spacing: 12; padding: 16; width: parent.width
          Repeater {
            model: [["Latte", "#eff1f5", "#dce0e8", "#ccd0da"], ["Frappé", "#303446", "#232634", "#414559"], ["Macchiato", "#24273a", "#181926", "#363a4f"], ["Mocha", "#1e1e2e", "#11111b", "#313244"]]
            Column { required property var modelData; width: (parent.width - 32 - 36) / 4; spacing: 8
              Rectangle { width: parent.width; height: width * 0.625; radius: 9; color: modelData[1]; border.width: 2; border.color: modelData[0] === "Mocha" ? Theme.accent : "transparent"
                Rectangle { x: parent.width * .08; y: parent.height * .10; width: parent.width * .84; height: parent.height * .10; radius: 3; color: modelData[3] }
                Rectangle { x: parent.width * .08; y: parent.height * .28; width: parent.width * .45; height: parent.height * .60; radius: 4; color: modelData[2] } }
              T { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[0]; font.pixelSize: 12; color: modelData[0] === "Mocha" ? Theme.text : Theme.subtext0; font.weight: modelData[0] === "Mocha" ? Font.DemiBold : Font.Medium } }
          } } }
      Group {
        Item { width: parent.width; height: 48
          Column { x: 14; anchors.verticalCenter: parent.verticalCenter
            T { text: "Accent colour" }
            T { text: Prefs.accent.charAt(0).toUpperCase() + Prefs.accent.slice(1); font.pixelSize: 11; color: Theme.overlay1 } }
          Row { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } spacing: 9
            Repeater {
              model: ["rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender"]
              Rectangle { required property string modelData; width: 20; height: 20; radius: 10; color: Theme.c(modelData)
                border.width: Prefs.accent === modelData ? 2 : 0; border.color: Theme.base
                Rectangle { visible: Prefs.accent === modelData; anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: "transparent"; border.width: 2; border.color: Theme.c(modelData); z: -1 }
                MouseArea { anchors.fill: parent; onClicked: Prefs.set("accent", modelData) } } } } }
        SRow { first: false; r: ({ k: "toggle", l: "Reduce transparency", key: "reduceTrans" }) }
        SRow { first: false; r: ({ k: "toggle", l: "Show scroll bars", key: "scroll" }) } }
      Group {
        SRow { first: true; r: ({ k: "select", ic: "type", c: "mauve", l: "Interface font", v: "Quicksand" }) }
        SRow { first: false; r: ({ k: "select", ic: "terminal", c: "lavender", l: "Monospace font", v: "JetBrainsMono Nerd Font 12" }) }
        SRow { first: false; r: ({ k: "select", ic: "layers", c: "blue", l: "Icon theme", v: "Papirus-Dark (mocha)" }) }
        SRow { first: false; r: ({ k: "select", ic: "mouse", c: "overlay", l: "Cursor", v: "catppuccin-mocha-dark" }) } }
    }
  }
  Component {
    id: displays
    Column {
      spacing: 14
      Group {
        Column { width: parent.width; topPadding: 22; bottomPadding: 16
          Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 220; height: 124; radius: 8; color: "#151521"; border.width: 6; border.color: Theme.crust
            Rectangle { x: 6; y: 5; width: parent.width - 12 - 12; height: 6; radius: 3; color: Qt.rgba(205/255, 214/255, 244/255, .15) } }
          Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 40; height: 18; color: Theme.surface1; radius: 2 }
          T { anchors.horizontalCenter: parent.horizontalCenter; topPadding: 10; text: (Sys.specs.find(s => s[0] === "Display") || ["", "Display"])[1].split(" ")[0]; font.weight: Font.DemiBold }
          M { anchors.horizontalCenter: parent.horizontalCenter; text: (Sys.specs.find(s => s[0] === "Display") || ["", ""])[1]; font.pixelSize: 11; color: Theme.overlay1 } } }
      Group {
        SRow { first: true; r: ({ k: "select", ic: "monitor", c: "sky", l: "Resolution", v: "1920 × 1080" }) }
        Item { width: parent.width; height: 48
          TileIc { x: 14; anchors.verticalCenter: parent.verticalCenter; box: 30; icon: "zap"; tone: "sky" }
          T { x: 56; anchors.verticalCenter: parent.verticalCenter; text: "Refresh rate" }
          Rectangle { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } width: segr.implicitWidth + 4; height: 28; radius: 8; color: Theme.surface0
            Row { id: segr; anchors.centerIn: parent; spacing: 0
              Repeater { model: ["60 Hz", "120 Hz", "144 Hz"]
                Rectangle { required property string modelData; width: sg.implicitWidth + 20; height: 24; radius: 6; color: modelData === "144 Hz" ? Theme.surface2 : "transparent"
                  T { id: sg; anchors.centerIn: parent; text: modelData; font.pixelSize: 12; color: modelData === "144 Hz" ? Theme.text : Theme.subtext0; font.weight: modelData === "144 Hz" ? Font.DemiBold : Font.Medium } } } } } }
        SRow { first: false; r: ({ k: "select", ic: "scan", c: "overlay", l: "Scale", v: "100%" }) }
        SRow { first: false; r: ({ k: "toggle", ic: "gauge", c: "green", l: "Variable refresh rate", key: "vrr", s: "G-SYNC Compatible" }) } }
      Group {
        SRow { first: true; r: ({ k: "range", ic: "sun", c: "yellow", l: "Brightness", key: "bri" }) }
        SRow { first: false; r: ({ k: "toggle", ic: "moon", c: "peach", l: "Night Light", key: "night", s: "wlsunset · " + Prefs.nightTemp + "K" }) } }
    }
  }
  Component {
    id: wallpaper
    Column {
      spacing: 14
      Group {
        Grid { columns: 3; spacing: 12; padding: 16; width: parent.width
          Repeater {
            model: [["unix", "UNIX Cloud"], ["mocha", "Mocha Glow"], ["plain", "Crust"], ["dusk", "Dusk"], ["ocean", "Sapphire"], ["forest", "Forest"], ["rose", "Rose"]]
            Rectangle { required property var modelData; width: (parent.width - 32 - 24) / 3; height: width * 0.625; radius: 10; clip: true
              color: ({ unix: "#11111b", mocha: "#151521", plain: "#11111b", dusk: "#1b1726", ocean: "#121826", forest: "#121a17", rose: "#1c1520" })[modelData[0]]
              border.width: 2; border.color: Prefs.wall === modelData[0] ? Theme.accent : "transparent"
              Image { anchors.fill: parent; visible: modelData[0] === "unix"; source: Qt.resolvedUrl("../assets/unix.jpg"); fillMode: Image.PreserveAspectCrop; sourceSize.width: 400; asynchronous: true }
              T { x: 8; y: parent.height - height - 6; text: modelData[1]; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.subtext1 }
              MouseArea { anchors.fill: parent; onClicked: Prefs.set("wall", modelData[0]) } } } } }
      Group {
        SRow { first: true; r: ({ k: "select", ic: "image", c: "teal", l: "Fit", v: "Fill" }) }
        SRow { first: false; r: ({ k: "select", ic: "sparkle", c: "mauve", l: "Transition", v: "none" }) } }
    }
  }
}
