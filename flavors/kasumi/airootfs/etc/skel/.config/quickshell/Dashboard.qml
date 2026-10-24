import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Quickshell 1.0
import Quickshell.Wayland 1.0
import "."

PanelWindow {
    id: dashboardWindow
    anchors {
        top: true
        right: true
    }
    margins {
        top: 56
        right: 16
    }
    width: 340
    height: 420
    color: "transparent"

    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.94)
        border.color: Theme.outline
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Header: Title and Close button
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Control Center"
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.primary
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: closeMouse.containsMouse ? Theme.surfaceVariant : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dashboardWindow.visible = false
                    }
                }
            }

            // Quick Toggles Grid (Wi-Fi, Bluetooth, Performance, Do Not Disturb)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                // Wi-Fi Toggle
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.smallRadius
                    color: wifiActive ? Theme.primaryContainer : Theme.surfaceVariant
                    property bool wifiActive: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        Text {
                            text: "󰤨"
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            color: wifiActive ? Theme.primary : Theme.onSurfaceVariant
                        }
                        ColumnLayout {
                            Text {
                                text: "Wi-Fi"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.onSurface
                            }
                            Text {
                                text: "Connected"
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.wifiActive = !parent.wifiActive
                    }
                }

                // Bluetooth Toggle
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.smallRadius
                    color: btActive ? Theme.primaryContainer : Theme.surfaceVariant
                    property bool btActive: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        Text {
                            text: "󰂯"
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            color: btActive ? Theme.secondary : Theme.onSurfaceVariant
                        }
                        ColumnLayout {
                            Text {
                                text: "Bluetooth"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.onSurface
                            }
                            Text {
                                text: "Active"
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.btActive = !parent.btActive
                    }
                }
            }

            // Volume Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰕾 Volume"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.onSurface
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(volSlider.value * 100) + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.primary
                    }
                }
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    value: 0.70
                }
            }

            // Brightness Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰃠 Brightness"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.onSurface
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(brightSlider.value * 100) + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.tertiary
                    }
                }
                Slider {
                    id: brightSlider
                    Layout.fillWidth: true
                    from: 0.1
                    to: 1.0
                    value: 0.85
                }
            }

            Item { Layout.fillHeight: true }

            // Footer Quick Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    Layout.fillWidth: true
                    text: "Lock"
                    onClicked: Quickshell.process(["loginctl", "lock-session"]).start()
                }
                Button {
                    Layout.fillWidth: true
                    text: "Reboot"
                    onClicked: Quickshell.process(["systemctl", "reboot"]).start()
                }
                Button {
                    Layout.fillWidth: true
                    text: "Power Off"
                    onClicked: Quickshell.process(["systemctl", "poweroff"]).start()
                }
            }
        }
    }
}
