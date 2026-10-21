import Quickshell
import Quickshell.Io
import QtQuick
import "../../services"
import "../../components"

// Spotlight-style launcher: apps, links, calculator (qalc) and a web-search fallback
PanelBox {
  id: root
  implicitWidth: 560
  radius: 16; pad: 10
  property string query: ""
  property string calc: ""
  property int cur: 0

  readonly property var apps: {
    var q = query.trim().toLowerCase()
    var all = DesktopEntries.applications.values.filter(e => !e.noDisplay)
    if (!q) return all.sort((a, b) => a.name.localeCompare(b.name)).slice(0, 7)
    return all.filter(e => e.name.toLowerCase().indexOf(q) >= 0 || (e.genericName || "").toLowerCase().indexOf(q) >= 0 || (e.keywords || []).join(" ").toLowerCase().indexOf(q) >= 0)
              .sort((a, b) => (a.name.toLowerCase().indexOf(q) === 0 ? 0 : 1) - (b.name.toLowerCase().indexOf(q) === 0 ? 0 : 1) || a.name.localeCompare(b.name)).slice(0, 7)
  }
  readonly property bool isLink: /^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,}(\/\S*)?$/i.test(query.trim())
  readonly property var rows: {
    var r = []
    if (calc !== "") r.push({ kind: "calc", title: calc, sub: "Calculator · Enter copies the result", icon: "hash" })
    if (isLink) r.push({ kind: "link", title: query.trim(), sub: "Open link", icon: "globe" })
    apps.forEach(a => r.push({ kind: "app", entry: a, title: a.name, sub: a.genericName || a.comment || "", iconUrl: Quickshell.iconPath(a.icon, true) }))
    if (query.trim() !== "") r.push({ kind: "web", title: "Search DuckDuckGo for “" + query.trim() + "”", sub: "Web", icon: "search" })
    return r
  }
  onRowsChanged: if (cur >= rows.length) cur = 0
  onQueryChanged: {
    cur = 0
    var q = query.trim()
    if (q !== "" && /^[0-9(\-+.]/.test(q) && /[0-9)]/.test(q) && /[-+*\/^%()]|sqrt|sin|cos|log/.test(q)) { calcProc.command = ["qalc", "-t", q]; calcProc.running = true } else calc = ""
  }
  Process { id: calcProc; stdout: StdioCollector { onStreamFinished: { var t = text.trim(); root.calc = t && t.indexOf("error") < 0 ? t : "" } } }

  function activate(r) {
    if (!r) return
    Sys.close()
    if (r.kind === "app") r.entry.execute()
    else if (r.kind === "link") Quickshell.execDetached(["xdg-open", /^https?:/.test(r.title) ? r.title : "https://" + r.title])
    else if (r.kind === "calc") Quickshell.execDetached(["wl-copy", r.title.replace(/^.*=\s*/, "")])
    else if (r.kind === "web") Quickshell.execDetached(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(query.trim())])
  }

  Column {
    width: parent.width; spacing: 8
    Rectangle {
      width: parent.width; height: 44; radius: 11; color: Theme.surface0
      Icon { x: 14; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 17; color: Theme.overlay1 }
      TextInput {
        id: input
        anchors { fill: parent; leftMargin: 44; rightMargin: 14 }
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text; font.family: Theme.ui; font.pixelSize: 16; font.weight: Font.Medium
        focus: true; clip: true; selectByMouse: true
        onTextChanged: root.query = text
        Keys.onDownPressed: root.cur = Math.min(root.rows.length - 1, root.cur + 1)
        Keys.onUpPressed: root.cur = Math.max(0, root.cur - 1)
        Keys.onReturnPressed: root.activate(root.rows[root.cur])
        Keys.onEscapePressed: Sys.close()
        Component.onCompleted: forceActiveFocus()
        T { visible: !input.text; anchors.verticalCenter: parent.verticalCenter; text: "Search apps, files and the web"; font.pixelSize: 16; color: Theme.overlay1 }
      }
    }
    Column {
      width: parent.width; spacing: 2
      Repeater {
        model: root.rows
        Rectangle {
          required property var modelData; required property int index
          width: parent.width; height: 42; radius: 9
          color: index === root.cur ? Theme.accent : (rm.containsMouse ? Theme.hover5 : "transparent")
          Item { x: 10; anchors.verticalCenter: parent.verticalCenter; width: 26; height: 26
            Icon { visible: !!modelData.icon; anchors.centerIn: parent; name: modelData.icon || ""; size: 17; color: index === root.cur ? Theme.crust : Theme.subtext1 }
            Image { visible: !modelData.icon; anchors.fill: parent; source: modelData.iconUrl || ""; sourceSize: Qt.size(52, 52); fillMode: Image.PreserveAspectFit } }
          Column { x: 46; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 56
            T { text: modelData.title; width: parent.width; elide: Text.ElideRight; font.weight: Font.DemiBold; color: index === root.cur ? Theme.crust : Theme.text }
            T { visible: modelData.sub !== ""; text: modelData.sub; width: parent.width; elide: Text.ElideRight; font.pixelSize: 11; color: index === root.cur ? Qt.rgba(17/255, 17/255, 27/255, .7) : Theme.overlay1 } }
          MouseArea { id: rm; anchors.fill: parent; hoverEnabled: true; onEntered: root.cur = index; onClicked: root.activate(modelData) }
        }
      }
    }
  }
}
