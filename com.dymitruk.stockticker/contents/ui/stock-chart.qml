import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    property bool isRed: true
    property string displayName: Plasmoid.configuration.displayName || "Stock"
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    
    // Adjust size based on form factor
    Layout.preferredWidth: {
        switch (Plasmoid.formFactor) {
            case PlasmaCore.Types.Panel:
                return 64
            default: // Planar (desktop)
                return 200
        }
    }
    
    Layout.preferredHeight: {
        switch (Plasmoid.formFactor) {
            case PlasmaCore.Types.Panel:
                return 32
            default: // Planar (desktop)
                return 200
        }
    }
    
    // Minimum sizes to ensure widget is always visible
    Layout.minimumWidth: 24
    Layout.minimumHeight: 24
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            isRed = !isRed
        }
    }
     
    Rectangle {
        id: redRectangle
        width: parent.width - 4
        height: parent.height - 4
        color: isRed ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.positiveTextColor
        anchors.centerIn: parent
        opacity: 0.7
        
        // Add some visual feedback for the form factor
        border.width: 1
        border.color: PlasmaCore.Theme.textColor
        radius: Math.min(width, height) * 0.2

        Text {
            anchors.centerIn: parent
            text: displayName + " v 1"
            color: PlasmaCore.Theme.textColor
            font.pixelSize: Math.min(parent.width, parent.height) * 0.3
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

