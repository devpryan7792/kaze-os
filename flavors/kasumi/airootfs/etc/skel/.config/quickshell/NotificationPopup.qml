import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell 1.0
import Quickshell.Wayland 1.0
import "."

PanelWindow {
    id: notificationWindow
    anchors {
        top: true
        right: true
    }
    margins {
        top: 56
        right: 16
    }
    width: 320
    height: notifCol.implicitHeight + 10
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay

    ColumnLayout {
        id: notifCol
        width: parent.width
        spacing: 8

        // Example dynamic notification card
        Rectangle {
            id: card
            Layout.fillWidth: true
            height: 72
            radius: Theme.smallRadius
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.95)
            border.color: Theme.outline
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: Theme.primaryContainer
                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        color: Theme.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Kaze Kasumi"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.onSurface
                    }
                    Text {
                        text: "Wayland Rice initialized successfully."
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
