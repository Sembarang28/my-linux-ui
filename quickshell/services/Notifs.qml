pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification daemon: history for the bell panel + short-lived toasts
Singleton {
  id: root
  property var items: []      // newest first: { n, time, toast }
  readonly property int count: items.length
  signal changed2()

  function timeAgo(t) {
    var s = Math.floor((Date.now() - t) / 1000)
    if (s < 60) return "now"
    if (s < 3600) return Math.floor(s / 60) + "m ago"
    if (s < 86400) return Math.floor(s / 3600) + "h ago"
    return Math.floor(s / 86400) + "d ago"
  }
  function dismiss(n) { n.dismiss() }
  function clearAll() { items.slice().forEach(i => i.n.dismiss()) }
  function iconFor(n) {
    var a = (n.appName || "").toLowerCase()
    if (a.indexOf("discord") >= 0 || a.indexOf("telegram") >= 0) return ["message", "lavender"]
    if (a.indexOf("spotify") >= 0) return ["headphones", "green"]
    if (a.indexOf("ghostty") >= 0 || a.indexOf("term") >= 0) return ["terminal", "mauve"]
    if (a.indexOf("pacman") >= 0 || a.indexOf("update") >= 0) return ["package", "peach"]
    if (a.indexOf("firefox") >= 0 || a.indexOf("zen") >= 0 || a.indexOf("chrome") >= 0) return ["globe", "peach"]
    return ["bell", "blue"]
  }

  NotificationServer {
    id: server
    keepOnReload: false
    bodySupported: true
    bodyMarkupSupported: false
    actionsSupported: true
    imageSupported: true
    onNotification: n => {
      n.tracked = true
      var it = { n: n, time: Date.now(), toast: !Prefs.dnd }
      root.items = [it].concat(root.items)
      n.closed.connect(() => { root.items = root.items.filter(x => x.n !== n) })
      if (it.toast) toastTimer.restart()
    }
  }
  property var toasts: []
  function refreshToasts() {
    var now = Date.now()
    var t = items.filter(i => i.toast && now - i.time < 6000).slice(0, 3)
    items.forEach(i => { if (i.toast && now - i.time >= 6000) i.toast = false })
    toasts = t
    return t.length > 0
  }
  Timer { id: toastTimer; interval: 500; repeat: true; onTriggered: if (!root.refreshToasts()) stop() }
  onItemsChanged: refreshToasts()
}
