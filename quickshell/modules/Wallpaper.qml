import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import "../services"

// Background layer. "unix" is the photo embedded in mocha-shell.html; the rest are the CSS gradients.
PanelWindow {
  id: win
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Background
  color: Theme.crust

  component Glow: Shape {
    id: g
    property real cx; property real cy; property real rx; property real ry; property color c
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: "transparent"
      fillGradient: RadialGradient {
        centerX: g.cx * g.width; centerY: g.cy * g.height; centerRadius: g.rx
        focalX: centerX; focalY: centerY
        GradientStop { position: 0; color: g.c }
        GradientStop { position: 0.6; color: Qt.rgba(g.c.r, g.c.g, g.c.b, 0) }
      }
      startX: 0; startY: 0
      PathLine { x: g.width; y: 0 } PathLine { x: g.width; y: g.height } PathLine { x: 0; y: g.height } PathLine { x: 0; y: 0 }
    }
  }
  function a(c, al) { return Qt.rgba(c.r, c.g, c.b, al) }

  Image {
    anchors.fill: parent; visible: Prefs.wall === "unix"
    source: Qt.resolvedUrl("../assets/unix.jpg"); fillMode: Image.PreserveAspectCrop; asynchronous: true
  }
  Rectangle {
    id: flat
    anchors.fill: parent; visible: Prefs.wall !== "unix"
    readonly property var tops: ({ mocha: "#151521", plain: "#11111b", dusk: "#1b1726", ocean: "#121826", forest: "#121a17", rose: "#1c1520" })
    gradient: Gradient { GradientStop { position: 0; color: flat.tops[Prefs.wall] || "#151521" } GradientStop { position: 1; color: "#11111b" } }
    Glow { visible: Prefs.wall === "mocha"; cx: .78; cy: 1.12; rx: 700; c: win.a(Theme.accent, .30) }
    Glow { visible: Prefs.wall === "mocha"; cx: .08; cy: -.1; rx: 560; c: Qt.rgba(137/255, 180/255, 250/255, .10) }
    Glow { visible: Prefs.wall === "dusk"; cx: .5; cy: 1.2; rx: 600; c: Qt.rgba(250/255, 179/255, 135/255, .20) }
    Glow { visible: Prefs.wall === "ocean"; cx: .2; cy: 1.1; rx: 600; c: Qt.rgba(116/255, 199/255, 236/255, .22) }
    Glow { visible: Prefs.wall === "forest"; cx: .8; cy: 0; rx: 650; c: Qt.rgba(166/255, 227/255, 161/255, .14) }
    Glow { visible: Prefs.wall === "rose"; cx: .5; cy: -.2; rx: 650; c: Qt.rgba(245/255, 194/255, 231/255, .18) }
  }
}
