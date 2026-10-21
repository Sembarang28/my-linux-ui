import QtQuick
import "../../services"
import "../../components"

// File / Edit / View / Go / Window / Help (static lists; entries with `a` run a niri action)
PanelBox {
  id: root
  property string name: "File"
  pad: 5; implicitWidth: 240
  readonly property var menus: ({
    File: [{ l: "New Window", k: "Ctrl ⇧ N" }, { l: "New Tab", k: "Ctrl ⇧ T" }, { l: "Split Right", k: "Ctrl ⇧ O" }, { l: "Split Down", k: "Ctrl ⇧ E" }, "-",
           { l: "Close Tab", k: "Ctrl ⇧ W" }, { l: "Close Window", k: "Super Q", a: ["close-window"] }],
    Edit: [{ l: "Undo", k: "Ctrl Z", d: true }, { l: "Redo", k: "Ctrl ⇧ Z", d: true }, "-", { l: "Copy", k: "Ctrl ⇧ C" }, { l: "Paste", k: "Ctrl ⇧ V" }, { l: "Select All", k: "Ctrl ⇧ A" }, "-", { l: "Find…", k: "Ctrl ⇧ F" }],
    View: [{ l: "Increase Font Size", k: "Ctrl +" }, { l: "Decrease Font Size", k: "Ctrl -" }, { l: "Reset Font Size", k: "Ctrl 0" }, "-",
           { l: "Toggle Fullscreen", k: "Super F", a: ["fullscreen-window"] }, { l: "Toggle Floating", k: "Super V", a: ["toggle-window-floating"] }],
    Go: [{ l: "Workspace Up", k: "Super U", a: ["focus-workspace-up"] }, { l: "Workspace Down", k: "Super I", a: ["focus-workspace-down"] }, "-",
         { l: "Focus Column Left", k: "Super H", a: ["focus-column-left"] }, { l: "Focus Column Right", k: "Super L", a: ["focus-column-right"] }, "-",
         { l: "Home", i: "folder", o: "~" }, { l: "Downloads", i: "download", o: "~/Downloads" }],
    Window: [{ l: "Minimize", k: "Super M", d: true }, { l: "Maximize Column", k: "Super F", a: ["maximize-column"] }, { l: "Center Column", k: "Super C", a: ["center-column"] }, "-",
             { l: "Move to Workspace Up", k: "Super ⇧ U", a: ["move-window-to-workspace-up"] }, { l: "Move to Workspace Down", k: "Super ⇧ I", a: ["move-window-to-workspace-down"] }, "-",
             { l: "Overview", k: "Super O", a: ["toggle-overview"] }],
    Help: [{ l: Sys.focusedApp + " Documentation" }, { l: "Keyboard Shortcuts", k: "Super ⇧ /", a: ["show-hotkey-overlay"] }, "-", { l: "Report an Issue…" }]
  })
  Column {
    width: parent.width
    Repeater {
      model: root.menus[root.name] || []
      Loader {
        required property var modelData
        width: parent.width
        sourceComponent: modelData === "-" ? sep : item
        Component { id: sep; MenuSep {} }
        Component {
          id: item
          MenuItem {
            label: modelData.l; kbd: modelData.k || ""; icon: modelData.i || ""; disabled: !!modelData.d
            onClicked: {
              Sys.close()
              if (modelData.a) Sys.niriAction(modelData.a)
              else if (modelData.o) Quickshell.execDetached(["xdg-open", modelData.o.replace("~", Quickshell.env("HOME"))])
            }
          }
        }
      }
    }
  }
}
