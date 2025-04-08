import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    
    property alias cfg_displayName: displayNameField.text

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        TextField {
            id: displayNameField
            Kirigami.FormData.label: i18n("Display Name:")
            Layout.fillWidth: true
            text: plasmoid.configuration.displayName || "Stock"
        }
    }
} 