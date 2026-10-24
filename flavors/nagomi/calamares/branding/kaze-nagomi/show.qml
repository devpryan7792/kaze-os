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
                    text: "Kaze Nagomi (和 - Harmony)"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#48d1cc"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "The Polished, Unbreakable Daily Driver Arch Workstation."
                    font.pixelSize: 14
                    color: "#e0fffa"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "KDE Plasma 6 + Dual Software Stores"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#7aa2f7"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Seamless fractional scaling and gesture navigation.\nDiscover with Flathub for sandboxed apps, Pamac for Arch & AUR."
                    font.pixelSize: 14
                    color: "#e0fffa"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Battery Optimization & Recovery"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#b4f9f8"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Integrated Power Profiles Daemon for extended laptop battery life.\nAutomatic Snapper snapshots protect your system."
                    font.pixelSize: 14
                    color: "#e0fffa"
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
