import QtQuick 2.15
import Quickshell 1.0
import Quickshell.Io 1.0
import "."

ShellRoot {
    id: shellRoot

    // Top status bar instance
    Bar { id: mainBar }

    // Control center dashboard instance
    Dashboard { id: mainDashboard }

    // Application search launcher instance
    Launcher { id: mainLauncher }

    // Notifications instance
    NotificationPopup { id: mainNotif }

    // Wallpaper visual picker instance
    WallpaperPicker { id: mainWallPicker }

    function toggleLauncher() {
        mainLauncher.visible = !mainLauncher.visible;
    }

    function toggleDashboard() {
        mainDashboard.visible = !mainDashboard.visible;
    }

    function toggleWallpaperPicker() {
        mainWallPicker.visible = !mainWallPicker.visible;
    }

    // QuickShell IPC Handlers
    IpcHandler {
        target: "launcher"
        function toggle() {
            shellRoot.toggleLauncher();
        }
    }

    IpcHandler {
        target: "dashboard"
        function toggle() {
            shellRoot.toggleDashboard();
        }
    }

    IpcHandler {
        target: "wallpaperPicker"
        function toggle() {
            shellRoot.toggleWallpaperPicker();
        }
    }

    IpcHandler {
        target: "theme"
        function reload() {
            Theme.reload();
        }
    }
}
