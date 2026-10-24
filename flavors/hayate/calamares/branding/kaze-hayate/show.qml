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
                    text: "Kaze Hayate (疾風 - Swift Gale)"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#ff5555"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Uncompromising Low-Latency Performance & Esports Gaming."
                    font.pixelSize: 14
                    color: "#f8f8f2"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "CachyOS Kernel + BORE Scheduler"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#ffb86c"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Compiled with -O3 and x86-64-v3 optimizations.\nDynamic burst-oriented response for rock-solid 1% low frame-rates."
                    font.pixelSize: 14
                    color: "#f8f8f2"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    text: "Ananicy-CPP + ZRAM Engine"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#50fa7b"
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Automated real-time task priority boosting.\nFull RAM zstd-compressed swap eliminates disk thrashing."
                    font.pixelSize: 14
                    color: "#f8f8f2"
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
