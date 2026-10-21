import Quickshell.Services.Pipewire
import QtQuick
import "../../services"
import "../../components"

PanelBox {
  id: root
  implicitWidth: 340
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
  readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)
  PwObjectTracker { objects: root.sinks.concat(root.streams).concat(Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []) }
  function sinkIcon(n) { var d = (n.description || n.name).toLowerCase(); return d.match(/headphone|bluez|wh-|airpods|headset/) ? "headphones" : d.match(/hdmi|display|dp|monitor|vg2/) ? "monitor" : "volume" }
  function appIcon(n) { var a = (n.properties["application.name"] || n.name).toLowerCase(); return a.match(/spotify|music/) ? ["headphones", "green"] : a.match(/firefox|zen|chrom/) ? ["globe", "peach"] : a.match(/discord|telegram/) ? ["message", "lavender"] : ["volume", "pink"] }

  Column {
    width: parent.width
    PnlHead { icon: "volume"; iconColor: Theme.pink; title: "Sound"; meta: "PipeWire" }
    Item { width: 1; height: 12 }
    SliderRow { width: parent.width; icon: "volume"; value: Sys.volume; onMoved: v => Sys.setVolume(v) }
    PnlSec { text: "Output" }
    Repeater {
      model: root.sinks
      Li { required property var modelData
           icon: root.sinkIcon(modelData); title: modelData.description || modelData.name; sub: modelData.name; on: Pipewire.defaultAudioSink === modelData
           onClicked: Pipewire.preferredDefaultAudioSink = modelData
           Icon { visible: Pipewire.defaultAudioSink === modelData; name: "check"; size: 14; color: Theme.overlay1 } }
    }
    PnlSec { text: "Input" + (Pipewire.defaultAudioSource ? " · " + (Pipewire.defaultAudioSource.description || "") : "") }
    SliderRow { width: parent.width; icon: "mic"; value: Sys.mic; onMoved: v => Sys.setMic(v) }
    PnlSec { visible: root.streams.length > 0; text: "Applications" }
    Repeater {
      model: root.streams
      SliderRow { required property var modelData
        width: parent.width; height: 26
        icon: root.appIcon(modelData)[0]; iconColor: Theme.c(root.appIcon(modelData)[1])
        value: modelData.audio.volume * 100; onMoved: v => modelData.audio.volume = v / 100 }
    }
    PnlFoot { LinkBtn { text: Sys.muted ? "Unmute" : "Mute"; onClicked: Sys.toggleMute() } LinkBtn { text: "Sound Settings…"; onClicked: Sys.doAction("settings:sound") } }
  }
}
