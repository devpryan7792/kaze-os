import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell 1.0
import Quickshell.Wayland 1.0
import "."

PanelWindow {
    id: pickerWindow
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    MouseArea {
        anchors.fill: parent
        onClicked: pickerWindow.visible = false
    }

    Rectangle {
        width: 680
        height: 480
        anchors.centerIn: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.96)
        border.color: Theme.primary
        border.width: 1

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰸉 Select Wallpaper"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.primary
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "🎲 Random"
                    onClicked: {
                        pickerWindow.visible = false;
                        Quickshell.process(["kaze-cli", "wallpaper", "random"]).start();
                    }
                }
            }

            GridView {
                id: wallGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 200
                cellHeight: 140
                clip: true

                model: ListModel {
                    ListElement { title: "Neon Fuji"; file: "/usr/share/backgrounds/kaze/kaze-neon-fuji.svg" }
                    ListElement { title: "Cyber Mist"; file: "/usr/share/backgrounds/kaze/kaze-cyber-mist.svg" }
                    ListElement { title: "Serene Flow"; file: "/usr/share/backgrounds/kaze/kaze-serene-flow.svg" }
                    ListElement { title: "Minimal Wind"; file: "/usr/share/backgrounds/kaze/kaze-minimal-wind.svg" }
                }

                delegate: Rectangle {
                    width: 184
                    height: 120
                    radius: Theme.smallRadius
                    color: Theme.surfaceVariant
                    border.color: wallMouse.containsMouse ? Theme.primary : Theme.outline
                    border.width: wallMouse.containsMouse ? 2 : 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Image {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: model.file
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.title
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.onSurface
                        }
                    }

                    MouseArea {
                        id: wallMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pickerWindow.visible = false;
                            Quickshell.process(["kaze-cli", "wallpaper", model.file]).start();
                        }
                    }
                }
            }
        }
    }
}
