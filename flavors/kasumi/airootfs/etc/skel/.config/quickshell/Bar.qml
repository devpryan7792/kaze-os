import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell 1.0
import Quickshell.Wayland 1.0
import Quickshell.Hyprland 1.0
import "."

PanelWindow {
    id: barWindow
    anchors {
        top: true
        left: true
        right: true
    }
    height: 48
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 52

    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
            topMargin: 6
            bottomMargin: 2
        }
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.88)
        border.color: Theme.outline
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Left Section: Distro Icon & Workspaces
            RowLayout {
                spacing: 8

                // Distro Icon (Launcher trigger)
                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.smallRadius
                    color: launcherMouse.containsMouse ? Theme.primary : Theme.surfaceVariant

                    Text {
                        anchors.centerIn: parent
                        text: "風"
                        font.pixelSize: 16
                        font.bold: true
                        color: launcherMouse.containsMouse ? Theme.onPrimary : Theme.primary
                    }

                    MouseArea {
                        id: launcherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shellRoot.toggleLauncher()
                    }
                }

                // Workspace Indicators
                Row {
                    spacing: 6
                    Repeater {
                        model: 5
                        Rectangle {
                            width: active ? 24 : 10
                            height: 10
                            radius: 5
                            property bool active: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === (index + 1)) : (index === 0)
                            color: active ? Theme.primary : Theme.outline

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }
            }

            // Center Section: Focused Window Title
            Item {
                Layout.fillWidth: true
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 40, 400)
                    text: Hyprland.activeWindow ? (Hyprland.activeWindow.title || "Kaze OS") : "Kaze OS (風)"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.onSurface
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Right Section: Quick Stats & Dashboard Toggle
            RowLayout {
                spacing: 10

                // Wallpaper Switcher Button
                Rectangle {
                    width: 30
                    height: 30
                    radius: Theme.smallRadius
                    color: wallMouse.containsMouse ? Theme.surfaceVariant : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰸉"
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        color: Theme.tertiary
                    }

                    MouseArea {
                        id: wallMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shellRoot.toggleWallpaperPicker()
                    }
                }

                // Clock / Date Widget
                Rectangle {
                    height: 30
                    implicitWidth: clockText.implicitWidth + 18
                    radius: Theme.smallRadius
                    color: Theme.surfaceVariant

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󰥔"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.primary
                        }

                        Text {
                            id: clockText
                            text: Qt.formatDateTime(new Date(), "hh:mm")
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.onSurface
                        }
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
                    }
                }

                // Dashboard Toggle Button
                Rectangle {
                    width: 32
                    height: 30
                    radius: Theme.smallRadius
                    color: dashMouse.containsMouse ? Theme.primary : Theme.surfaceVariant

                    Text {
                        anchors.centerIn: parent
                        text: "󱗼"
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        color: dashMouse.containsMouse ? Theme.onPrimary : Theme.secondary
                    }

                    MouseArea {
                        id: dashMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shellRoot.toggleDashboard()
                    }
                }
            }
        }
    }
}
