pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  function path(p) { return Qt.resolvedUrl("../" + p).toString().replace("file://", "") }
  readonly property string user: Quickshell.env("USER") || "user"
  property string fullName: "Agil Fikriawan"
  readonly property string initials: fullName.split(" ").map(w => w[0]).slice(0, 2).join("").toUpperCase()
  readonly property string firstName: fullName.split(" ")[0]

  // ---------------- panel / window / dialog state ----------------
  property string panel: ""          // arch | menu:File | stats | notifications | power | brightness | sound | bluetooth | wifi | quick | calendar | launcher
  property real anchorX: 0           // anchor button geometry in bar-window coordinates
  property real anchorW: 0
  function openPanel(name, item) {
    if (panel === name) { panel = ""; return }
    if (item) { var p = item.mapToItem(null, 0, 0); anchorX = p.x; anchorW = item.width }
    panel = name
  }
  function close() { panel = "" }
  function toggle(name) { panel = (panel === name ? "" : name) }   // for IPC

  property bool aboutOpen: false
  property bool settingsOpen: false
  property string settingsPane: "general"
  property string settingsSub: ""
  property bool forceQuitOpen: false
  property string dialog: ""         // restart | shutdown | logout
  property bool locked: false
  property bool sleeping: false
  function openSettings(pane) { close(); settingsPane = pane || "general"; settingsSub = ""; settingsOpen = true }
  function run(cmd) { Quickshell.execDetached(cmd); refreshSoon.restart() }
  function sh(cmd) { Quickshell.execDetached(["sh", "-c", cmd]) }
  function niriAction(args) { Quickshell.execDetached(["niri", "msg", "action"].concat(args)) }

  function doAction(a) {
    close()
    if (a === "about") aboutOpen = true
    else if (a === "settings") openSettings("general")
    else if (a.indexOf("settings:") === 0) openSettings(a.slice(9))
    else if (a === "forcequit") forceQuitOpen = true
    else if (a === "lock") locked = true
    else if (a === "sleep") sleeping = true
    else if (a === "restart" || a === "shutdown" || a === "logout") dialog = a
    else if (a === "screenshot") niriAction(["screenshot"])
  }
  function confirmDialog() {
    var d = dialog; dialog = ""
    if (d === "restart") Quickshell.execDetached(["systemctl", "reboot"])
    else if (d === "shutdown") Quickshell.execDetached(["systemctl", "poweroff"])
    else if (d === "logout") Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"])
  }
  onSleepingChanged: if (sleeping) Quickshell.execDetached(["niri", "msg", "action", "power-off-monitors"])

  // ---------------- stats ----------------
  property real cpu: 0
  property real gpu: 0
  property real ram: 0
  property string cpuTemp: "--"
  property string gpuTemp: "--"
  property string ramTemp: "--"
  property int cpuT: 0
  property int gpuT: 0
  property int ramT: 0
  property real ramUsed: 0
  property real ramTotal: 0
  property real swapUsed: 0
  property real swapTotal: 0
  property real diskUsed: 0
  property real diskTotal: 0
  property real gpuPow: 0
  property real gpuVram: 0
  property real gpuVramTotal: 0
  property int gpuFan: 0
  property real netDown: 0
  property real netUp: 0
  property int cpuMhz: 0
  property string uptime: ""
  property string load: ""
  property var cores: []
  property var hist: Array(40).fill(0)
  property var procs: []
  property var _prev: ({})
  property var _io: null
  function fmtRate(b) {
    var u = ["B/s", "KB/s", "MB/s", "GB/s"], i = 0
    while (b >= 1024 && i < 3) { b /= 1024; i++ }
    return (b >= 100 || i === 0 ? Math.round(b) : b.toFixed(1)) + " " + u[i]
  }

  // ---------------- controls ----------------
  property int volume: 0
  property int mic: 0
  property bool muted: false
  property bool wifi: false
  property string wifiName: ""
  property bool bt: false
  property bool airplane: false
  property string profile: "balanced"
  property int brightness: 50
  readonly property var profileNames: ({ "power-saver": "Power Saver", "balanced": "Balanced", "performance": "Performance" })
  readonly property string profileLabel: profileNames[profile] || "Balanced"

  function setVolume(v) { volume = Math.round(v); Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (volume / 100).toFixed(2)]) }
  function setMic(v) { mic = Math.round(v); Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", (mic / 100).toFixed(2)]) }
  function toggleMute() { muted = !muted; run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]) }
  function toggleWifi() { wifi = !wifi; run(["nmcli", "radio", "wifi", wifi ? "on" : "off"]) }
  function toggleBt() { bt = !bt; run(["bluetoothctl", "power", bt ? "on" : "off"]) }
  function setProfile(p) { profile = p; run(["busctl", "set-property", "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "net.hadess.PowerProfiles", "ActiveProfile", "s", p]) }
  function cycleProfile() {
    var o = ["power-saver", "balanced", "performance"]
    setProfile(o[(o.indexOf(profile) + 1) % 3])
  }
  function setBrightness(v) { brightness = Math.round(Math.max(0, Math.min(100, v))); ddcSet.restart() }

  // on-screen display after hardware keys
  property string osd: ""
  Timer { id: osdHide; interval: 1500; onTriggered: root.osd = "" }
  function showOsd(k) { osd = k; osdHide.restart() }
  function volumeStep(d) {
    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (Math.abs(d) / 100).toFixed(2) + (d > 0 ? "+" : "-"), "-l", "1.0"])
    showOsd("volume"); volumeRead.restart()
  }
  function volumeMute() { Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]); showOsd("volume"); volumeRead.restart() }
  function brightnessStep(d) { setBrightness(brightness + d); showOsd("brightness") }
  Timer { id: volumeRead; interval: 120; onTriggered: volumeGet.running = true }
  Process {
    id: volumeGet
    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
    stdout: StdioCollector { onStreamFinished: root.parseVol(text) }
  }
  function parseVol(t) {
    var m = t.match(/([0-9.]+)/)
    if (m) volume = Math.round(Number(m[1]) * 100)
    muted = t.indexOf("MUTED") >= 0
  }

  Timer { id: ddcSet; interval: 350; onTriggered: Quickshell.execDetached(["ddcutil", "setvcp", "10", String(root.brightness), "--noverify"]) }
  Process {
    running: true
    command: ["ddcutil", "getvcp", "10", "--brief"]
    stdout: StdioCollector {
      onStreamFinished: {
        var p = text.trim().split(/\s+/)
        if (p.length >= 5 && Number(p[4]) > 0) root.brightness = Math.round(Number(p[3]) / Number(p[4]) * 100)
      }
    }
  }

  // night light (wlsunset) and caffeine (idle inhibitor), driven by Prefs
  Process {
    running: Prefs.night
    command: ["wlsunset", "-t", String(Prefs.nightTemp), "-T", String(Prefs.nightTemp + 1), "-S", "00:00", "-s", "00:00"]
  }
  Process {
    running: Prefs.caffeine
    command: ["systemd-inhibit", "--what=idle:sleep", "--who=Quickshell", "--why=Caffeine", "sleep", "infinity"]
  }

  // ---------------- polling ----------------
  Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!stats.running) stats.running = true }
  Timer { id: refreshSoon; interval: 500; onTriggered: if (!stats.running) stats.running = true }
  Process {
    id: stats
    command: ["bash", root.path("scripts/stats.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        var d = {}, procs = [], cur = {}
        text.split("\n").forEach(l => {
          var i = l.indexOf("="); if (i <= 0) return
          var k = l.slice(0, i), v = l.slice(i + 1).trim()
          if (k === "proc") procs.push(v.split("|")); else d[k] = v
        })
        function usage(line, key) {
          var p = line.split(/\s+/).slice(1).map(Number)
          var idle = p[3] + (p[4] || 0), total = p.reduce((a, b) => a + b, 0)
          var pr = root._prev[key], r = -1
          if (pr && total - pr.total > 0) r = 100 * (1 - (idle - pr.idle) / (total - pr.total))
          root._prev[key] = { idle: idle, total: total }
          return r
        }
        var u = usage(d.stat || "", "all")
        if (u >= 0) { root.cpu = u; var h = root.hist.slice(1); h.push(u); root.hist = h }
        var cs = []
        for (var n = 0; n < 20; n++) { var l2 = d["cpu" + n]; if (l2 === undefined) break; var x = usage(l2, "c" + n); cs.push(x < 0 ? 0 : x) }
        if (cs.length) root.cores = cs
        root.ram = Number(d.ram || 0)
        root.ramUsed = Number(d.ramused || 0); root.ramTotal = Number(d.ramtotal || 0)
        root.swapUsed = Number(d.swapused || 0); root.swapTotal = Number(d.swaptotal || 0)
        root.diskUsed = Number(d.diskused || 0); root.diskTotal = Number(d.disktotal || 0)
        root.cpuT = d.ctemp ? Math.round(Number(d.ctemp)) : 0
        root.ramT = d.rtemp ? Math.round(Number(d.rtemp)) : 0
        root.gpuT = d.gtemp ? Math.round(Number(d.gtemp)) : 0
        root.cpuTemp = root.cpuT ? root.cpuT + "°" : "--"
        root.ramTemp = root.ramT ? root.ramT + "°" : "--"
        root.gpuTemp = root.gpuT ? root.gpuT + "°" : "--"
        if (d.gpu !== undefined) root.gpu = Number(d.gpu)
        root.gpuPow = Number(d.gpow) || 0
        root.gpuVram = Number(d.gvram || 0); root.gpuVramTotal = Number(d.gvramt || 0); root.gpuFan = Number(d.gfan || 0)
        if (d.dio && d.net) {
          var n2 = d.net.split(" ").map(Number), now = Date.now()
          if (root._io) {
            var dt = (now - root._io.t) / 1000
            if (dt > 0) { root.netDown = Math.max(0, (n2[0] - root._io.n[0]) / dt); root.netUp = Math.max(0, (n2[1] - root._io.n[1]) / dt) }
          }
          root._io = { t: now, n: n2 }
        }
        if (d.vol) root.parseVol(d.vol)
        var mm = (d.mic || "").match(/([0-9.]+)/); if (mm) root.mic = Math.round(Number(mm[1]) * 100)
        root.wifi = d.wifi === "enabled"
        root.wifiName = d.wname || ""
        root.bt = d.bt === "yes"
        var rf = d.rf || ""
        root.airplane = rf.indexOf("blocked") >= 0 && rf.indexOf("unblocked") < 0
        if (d.prof) root.profile = d.prof
        root.cpuMhz = Number(d.cpumhz || 0)
        root.uptime = d.uptime || ""; root.load = d.load || ""
        root.procs = procs
      }
    }
  }

  // ---------------- specs (About This PC) ----------------
  property var specs: []
  property string hostName: "archlinux"
  function loadSpecs() { if (!specsProc.running) specsProc.running = true }
  Process {
    id: specsProc
    command: ["bash", root.path("scripts/specs.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        var rows = []
        text.split("\n").forEach(l => {
          var i = l.indexOf("="); if (i <= 0) return
          var k = l.slice(0, i), v = l.slice(i + 1).trim()
          if (k === "_host") root.hostName = v; else rows.push([k, v])
        })
        root.specs = rows
      }
    }
  }

  // ---------------- weather (wttr.in, same source as the old config) ----------------
  property var weather: ({ city: "", temp: 0, cond: "—", feels: 0, hum: 0, wind: 0, hi: 0, lo: 0, hours: [], ok: false })
  property string weatherKind: "cloudSun"
  function weatherIcon(code) {
    code = Number(code)
    if (code === 113) return ["sun", "yellow"]
    if (code === 116) return ["cloudSun", "yellow"]
    if ([119, 122, 143, 248, 260].indexOf(code) >= 0) return ["cloud", "overlay"]
    if (code >= 176 && code <= 395) return ["cloudRain", "sapphire"]
    return ["cloud", "overlay"]
  }
  Process {
    id: weatherProc
    command: ["curl", "-s", "-m", "8", "wttr.in/?format=j1"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var j = JSON.parse(text), c = j.current_condition[0], t = j.weather[0]
          var area = j.nearest_area && j.nearest_area[0] ? j.nearest_area[0].areaName[0].value : ""
          var nowH = new Date().getHours(), hrs = []
          var all = j.weather[0].hourly.concat(j.weather[1] ? j.weather[1].hourly : [])
          var startIdx = 0
          for (var i = 0; i < all.length; i++) { if (Number(all[i].time) / 100 >= nowH && i < 8) { startIdx = i; break } }
          for (var k = 0; k < 6; k++) {
            var hh = all[Math.min(startIdx + k, all.length - 1)]
            var ic = root.weatherIcon(hh.weatherCode)
            var hour = Math.floor(Number(hh.time) / 100)
            if (hour >= 19 || hour < 5) ic = (ic[0] === "sun" || ic[0] === "cloudSun") ? ["moon", "lavender"] : ic
            hrs.push([k === 0 ? "Now" : (hour < 10 ? "0" : "") + hour + ":00", Number(hh.tempC), ic[0], ic[1]])
          }
          var ci = root.weatherIcon(c.weatherCode)
          root.weather = { city: area, temp: Number(c.temp_C), cond: c.weatherDesc[0].value, feels: Number(c.FeelsLikeC), hum: Number(c.humidity),
                           wind: Number(c.windspeedKmph), hi: Number(t.maxtempC), lo: Number(t.mintempC), hours: hrs, ok: true, icon: ci[0], color: ci[1] }
        } catch (e) {}
      }
    }
  }
  Timer { interval: 900000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weatherProc.running = true }

  // ---------------- niri ----------------
  property var workspaces: []     // [{id, idx, is_active, ...}]
  property var windows: []
  property string focusedApp: "Desktop"
  property string focusedAppId: ""
  property int activeWsIdx: 1
  property bool flush: false      // a tiled (full-size) window is on the active workspace
  readonly property int wsTotal: workspaces.filter(w => w.is_active || w.is_focused || windows.some(x => x.workspace_id === w.id)).length || 1
  function wsOccupied(idx) {
    var w = workspaces.find(x => x.idx === idx)
    return w ? windows.some(x => x.workspace_id === w.id) : false
  }
  function wsApps(idx) {
    var w = workspaces.find(x => x.idx === idx)
    if (!w) return "Empty"
    var a = windows.filter(x => x.workspace_id === w.id).map(x => appName(x.app_id, x.title))
    return a.length ? a.join(", ") : "Empty"
  }
  function appName(id, title) {
    if (id === "org.quickshell") return title
    var e = id ? DesktopEntries.heuristicLookup(id) : null
    return e ? e.name : (id || title || "")
  }
  function focusWorkspace(idx) { Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]) }
  function wsStep(d) { Quickshell.execDetached(["niri", "msg", "action", d > 0 ? "focus-workspace-down" : "focus-workspace-up"]) }

  Process {
    id: nWs
    command: ["niri", "msg", "--json", "workspaces"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var ws = JSON.parse(text); root.workspaces = ws
          var a = ws.find(w => w.is_focused) || ws.find(w => w.is_active)
          if (a) root.activeWsIdx = a.idx
        } catch (e) {}
        nWin.running = true
      }
    }
  }
  Process {
    id: nWin
    command: ["niri", "msg", "--json", "windows"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var ws = JSON.parse(text); root.windows = ws
          var act = root.workspaces.find(w => w.idx === root.activeWsIdx)
          var onWs = act ? ws.filter(w => w.workspace_id === act.id) : []
          root.flush = onWs.some(w => !w.is_floating)
          var f = ws.find(w => w.is_focused)
          if (!f && act) f = ws.find(w => w.id === act.active_window_id)
          root.focusedApp = f ? root.appName(f.app_id, f.title) : "Desktop"
          root.focusedAppId = f ? (f.app_id || "") : ""
        } catch (e) {}
      }
    }
  }
  Timer { id: niriRefresh; interval: 60; onTriggered: if (!nWs.running) nWs.running = true; else niriRefresh.restart() }
  Process { running: true; command: ["niri", "msg", "--json", "event-stream"]; stdout: SplitParser { onRead: niriRefresh.restart() } }
  Component.onCompleted: { niriRefresh.restart(); loadSpecs() }
}
