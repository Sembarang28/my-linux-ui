//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "services"
import "modules"

// Mocha Shell: Quickshell port of mocha-shell.html (Catppuccin Mocha · Quicksand · niri)
ShellRoot {
  Variants { model: Quickshell.screens; Wallpaper { required property var modelData; screen: modelData } }
  Bar { screen: Quickshell.screens[0] }
  Overlay { screen: Quickshell.screens[0] }
  Toasts { screen: Quickshell.screens[0] }
  Osd { screen: Quickshell.screens[0] }
  Dialogs { screen: Quickshell.screens[0] }
  LockScreen {}
  AboutWindow {}
  ForceQuitWindow {}
  SettingsWindow {}

  // qs ipc call panel toggle launcher|settings|wifi|bluetooth|sound|quick|calendar|stats
  IpcHandler {
    target: "panel"
    function toggle(name: string): void {
      if (name === "settings") { Sys.settingsOpen = !Sys.settingsOpen; Sys.close(); return }
      if (name === "about") { Sys.aboutOpen = !Sys.aboutOpen; Sys.close(); return }
      if (name === "forcequit") { Sys.forceQuitOpen = !Sys.forceQuitOpen; Sys.close(); return }
      if (name === "lock") { Sys.locked = true; Sys.close(); return }
      var known = ["launcher", "wifi", "bluetooth", "sound", "quick", "calendar", "stats", "power", "brightness", "notifications"]
      if (known.indexOf(name) >= 0) { Sys.anchorX = Quickshell.screens[0].width - 60; Sys.anchorW = 0; Sys.toggle(name) }
    }
    function close(): void { Sys.close() }
  }
  // qs ipc call osd volumeUp|volumeDown|volumeMute|brightnessUp|brightnessDown
  IpcHandler {
    target: "osd"
    function volumeUp(): void { Sys.volumeStep(5) }
    function volumeDown(): void { Sys.volumeStep(-5) }
    function volumeMute(): void { Sys.volumeMute() }
    function brightnessUp(): void { Sys.brightnessStep(5) }
    function brightnessDown(): void { Sys.brightnessStep(-5) }
  }
}
