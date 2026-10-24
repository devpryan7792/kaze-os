pragma Singleton
import QtQuick 2.15

QtObject {
    id: root

    // Reactive Color Tokens
    property color primary: "#7aa2f7"
    property color onPrimary: "#15161e"
    property color primaryContainer: "#3d59a1"
    property color onPrimaryContainer: "#d0d5fc"
    property color secondary: "#bb9af7"
    property color onSecondary: "#1d1a29"
    property color tertiary: "#7dcfff"
    property color onTertiary: "#101e26"
    property color surface: "#16161e"
    property color onSurface: "#c0caf5"
    property color surfaceVariant: "#24283b"
    property color onSurfaceVariant: "#a9b1d6"
    property color outline: "#414868"
    property color background: "#1a1b26"
    property color onBackground: "#c0caf5"
    property color error: "#f7768e"
    property color onError: "#ffffff"

    // Metrics & Styling Standards
    property int cornerRadius: 12
    property int smallRadius: 8
    property string fontFamily: "JetBrainsMono Nerd Font"

    function reload() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("colors.json"));
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.primary) root.primary = data.primary;
                    if (data.on_primary) root.onPrimary = data.on_primary;
                    if (data.primary_container) root.primaryContainer = data.primary_container;
                    if (data.on_primary_container) root.onPrimaryContainer = data.on_primary_container;
                    if (data.secondary) root.secondary = data.secondary;
                    if (data.on_secondary) root.onSecondary = data.on_secondary;
                    if (data.tertiary) root.tertiary = data.tertiary;
                    if (data.surface) root.surface = data.surface;
                    if (data.on_surface) root.onSurface = data.on_surface;
                    if (data.surface_variant) root.surfaceVariant = data.surface_variant;
                    if (data.outline) root.outline = data.outline;
                    if (data.background) root.background = data.background;
                } catch(e) {
                    console.log("Error parsing colors.json: " + e);
                }
            }
        };
        xhr.send();
    }

    Component.onCompleted: {
        reload();
    }
}
