import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: presentation
    width: 600
    height: 400

    Timer {
        interval: 6500
        running: true
        repeat: true
        onTriggered: {
            slideView.currentIndex = (slideView.currentIndex + 1) % slideView.count
        }
    }

    SwipeView {
        id: slideView
        anchors.fill: parent
        currentIndex: 0

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Kaze Kasumi (霞 - Mist)"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#bb9af7"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "The Ultimate Wayland Aesthetic Ricing Experience."
                    font.pixelSize: 14
                    color: "#c0caf5"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Modular Lua Hyprland & QuickShell"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#7dcfff"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Scriptable window manager configuration.\nHardware-accelerated QtQuick QML widgets and unified status bar."
                    font.pixelSize: 14
                    color: "#c0caf5"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Dynamic Material You Color Bus"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#9ece6a"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Matugen + awww transitions at 144Hz.\nWallpapers harmonize live across Hyprland, QuickShell, and Ghostty."
                    font.pixelSize: 14
                    color: "#c0caf5"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    PageIndicator {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
        count: slideView.count
        currentIndex: slideView.currentIndex
    }
}
