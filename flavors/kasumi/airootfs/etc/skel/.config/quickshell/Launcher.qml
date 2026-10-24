import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Quickshell 1.0
import Quickshell.Wayland 1.0
import "."

PanelWindow {
    id: launcherWindow
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Dismiss on clicking background scrim
    MouseArea {
        anchors.fill: parent
        onClicked: launcherWindow.visible = false
    }

    Rectangle {
        id: launcherCard
        width: 520
        height: 400
        anchors.centerIn: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.95)
        border.color: Theme.primary
        border.width: 1

        // Consume clicks inside the card
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Search Bar
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: Theme.smallRadius
                color: Theme.surfaceVariant
                border.color: searchInput.activeFocus ? Theme.primary : Theme.outline
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        color: Theme.primary
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Theme.onSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        selectByMouse: true
                        clip: true

                        Text {
                            text: "Type to search applications..."
                            color: Theme.onSurfaceVariant
                            visible: !parent.text && !parent.activeFocus
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                        }

                        Keys.onEscapePressed: launcherWindow.visible = false
                        Keys.onReturnPressed: {
                            if (appModel.count > 0) {
                                launchApp(appModel.get(0).cmd);
                            }
                        }
                    }
                }
            }

            // Quick App Grid / List
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6

                model: ListModel {
                    id: appModel
                    ListElement { name: "Ghostty Terminal"; cmd: "ghostty"; icon: "utilities-terminal"; desc: "GPU-accelerated terminal" }
                    ListElement { name: "Yazi File Manager"; cmd: "ghostty -e yazi"; icon: "system-file-manager"; desc: "Blazing fast terminal file manager" }
                    ListElement { name: "Firefox Browser"; cmd: "firefox"; icon: "firefox"; desc: "Fast, private Web Browser" }
                    ListElement { name: "Kaze Wallpaper Selector"; cmd: "kaze-cli wallpaper random"; icon: "preferences-desktop-wallpaper"; desc: "Shuffle wallpaper and Material You theme" }
                    ListElement { name: "Kaze Welcome Wizard"; cmd: "kaze-welcome"; icon: "kaze-logo"; desc: "First-boot setup assistant" }
                    ListElement { name: "Volume Control (Pavucontrol)"; cmd: "pavucontrol"; icon: "multimedia-volume-control"; desc: "PulseAudio / PipeWire mixer" }
                    ListElement { name: "Bluetooth Manager"; cmd: "blueman-manager"; icon: "preferences-system-bluetooth"; desc: "Bluetooth devices and pairings" }
                }

                delegate: Rectangle {
                    width: appList.width
                    height: 48
                    radius: Theme.smallRadius
                    color: itemMouse.containsMouse ? Theme.surfaceVariant : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            width: 30
                            height: 30
                            radius: 6
                            color: Theme.primaryContainer
                            Text {
                                anchors.centerIn: parent
                                text: "󰣆"
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                                color: Theme.primary
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: model.name
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                color: Theme.onSurface
                            }
                            Text {
                                text: model.desc
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(model.cmd)
                    }
                }
            }
        }
    }

    function launchApp(command) {
        launcherWindow.visible = false;
        Quickshell.process(command.split(" ")).start();
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }
}
