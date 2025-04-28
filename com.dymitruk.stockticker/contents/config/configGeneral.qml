import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    
    property alias cfg_displayName: displayNameField.text
    
    TextField {
        id: displayNameField
        Kirigami.FormData.label: i18n("Display Name:")
        placeholderText: i18n("Enter display name")
    }
} 