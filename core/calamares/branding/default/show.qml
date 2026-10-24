import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: presentation
    width: 600
    height: 400

    Timer {
        interval: 7000
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
            id: slide1
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Welcome to Kaze OS (風)"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#7aa2f7"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Motion, Flow, and Power — Built on Arch Linux."
                    font.pixelSize: 14
                    color: "#a9b1d6"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: slide2
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Unbreakable Rolling Release"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#bb9af7"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Automated 5-subvolume Btrfs snapshots with Snapper.\nRollback broken updates from GRUB in under 30 seconds."
                    font.pixelSize: 14
                    color: "#a9b1d6"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: slide3
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Engineered for Performance & Aesthetics"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#7dcfff"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Low-latency scheduling, hardware-accelerated UI,\nand curated package ecosystems."
                    font.pixelSize: 14
                    color: "#a9b1d6"
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
