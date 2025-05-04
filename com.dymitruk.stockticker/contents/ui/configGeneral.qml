import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    
    TextField {
        id: apiKeyField
        Kirigami.FormData.label: "Alpha Vantage API Key:"
        placeholderText: i18n("Enter your API key")
        text: plasmoid.configuration.alphaVantageApiKey
        onTextChanged: plasmoid.configuration.cfg_alphaVantageApiKey = text
    }

    TextField {
        id: tickerSymbolField
        Kirigami.FormData.label: "Ticker Symbol:"
        placeholderText: i18n("Enter ticker symbol (e.g., IBM)")
        text: plasmoid.configuration.tickerSymbol
        onTextChanged: plasmoid.configuration.cfg_tickerSymbol = text
    }
} 