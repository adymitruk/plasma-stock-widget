import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    
    property alias cfg_displayName: displayNameField.text
    property alias cfg_alphaVantageApiKey: apiKeyField.text
    
    TextField {
        id: displayNameField
        Kirigami.FormData.label: "Stock:"
        placeholderText: i18n("Enter display name")
    }

    TextField {
        id: apiKeyField
        Kirigami.FormData.label: "Alpha Vantage API Key:"
        placeholderText: i18n("Enter your API key")
    }
} 