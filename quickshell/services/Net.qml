pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Wi-Fi scanning / connecting through nmcli
Singleton {
  id: root
  property var networks: []
  property string status: ""
  property bool scanning: false

  function refresh() { scanning = true; listProc.running = true; rescan.running = true }
  function connectTo(ssid, password) {
    status = "Connecting to " + ssid + "…"
    connProc.target = ssid
    connProc.command = ["nmcli", "dev", "wifi", "connect", ssid].concat(password ? ["password", password] : [])
    connProc.running = true
  }
  Process { id: rescan; command: ["nmcli", "dev", "wifi", "rescan"]; onExited: listProc.running = true }
  Process {
    id: listProc
    command: ["bash", "-c", "nmcli -t -f NAME connection show; echo '---'; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list"]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = text.split("\n---\n")
        var saved = (parts[0] || "").split("\n").filter(x => x)
        var best = {}
        ;(parts[1] || "").split("\n").forEach(l => {
          if (!l) return
          var f = l.replace(/\\:/g, "\u0001").split(":").map(x => x.replace(/\u0001/g, ":"))
          var ssid = f[1]; if (!ssid) return
          var n = { ssid: ssid, signal: Number(f[2]), secure: (f[3] || "") !== "" && f[3] !== "--", active: f[0] === "*", saved: saved.indexOf(ssid) >= 0 }
          if (!best[ssid] || n.active || (!best[ssid].active && n.signal > best[ssid].signal)) best[ssid] = n
        })
        root.networks = Object.values(best).sort((a, b) => (b.active - a.active) || (b.signal - a.signal))
        root.scanning = false
      }
    }
  }
  Process {
    id: connProc
    property string target: ""
    stderr: StdioCollector { id: err }
    onExited: code => {
      root.status = code === 0 ? "" : "Failed: " + (err.text.trim().split("\n")[0] || "check the password")
      listProc.running = true
    }
  }
}
