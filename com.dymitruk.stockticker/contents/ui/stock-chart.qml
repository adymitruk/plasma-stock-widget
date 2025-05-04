import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Shapes 1.15
import QtQuick.XmlListModel 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    property string tickerSymbol: Plasmoid.configuration.cfg_tickerSymbol || "IBM"
    property string apiKey: Plasmoid.configuration.cfg_alphaVantageApiKey || "demo"
    property string currentPrice: "Loading..."
    property string errorMessage: ""
    
    // Sample data structure for OHLC (Open, High, Low, Close) data
    property var candleData: [
        { time: "10:00", open: 100, high: 105, low: 98, close: 103 },
        { time: "11:00", open: 103, high: 107, low: 102, close: 106 },
        { time: "12:00", open: 106, high: 108, low: 104, close: 105 },
        { time: "13:00", open: 105, high: 106, low: 103, close: 104 },
        { time: "14:00", open: 104, high: 105, low: 102, close: 103 }
    ]
    
    // Calculate min/max price across all data for scaling
    property real minPrice: candleData.reduce(function(min, candle) { return Math.min(min, candle.low); }, candleData[0].low)
    property real maxPrice: candleData.reduce(function(max, candle) { return Math.max(max, candle.high); }, candleData[0].high)
    property real priceRange: maxPrice - minPrice
    
    // Function to map price to Y coordinate
    function priceToY(price, chartHeight) {
        if (priceRange === 0) return chartHeight / 2; // Avoid division by zero
        return chartHeight * (1 - (price - minPrice) / priceRange);
    }
    
    // Function to fetch stock data from Alpha Vantage
    function fetchStockData() {
        errorMessage = ""; // Clear previous errors
        var localApiKey = "";
        var localTickerSymbol = "";

        // Safely get configuration values
        try {
            localApiKey = Plasmoid.configuration.cfg_alphaVantageApiKey || "demo";
            localTickerSymbol = Plasmoid.configuration.cfg_tickerSymbol || "IBM";
        } catch (e) {
            errorMessage = "Error reading configuration";
            console.error("Error reading Plasmoid configuration:", e);
            currentPrice = "Config Error";
            return;
        }

        // Use local copies of config values
        if (!localApiKey || localApiKey === "" || localApiKey === "demo") {
            errorMessage = "API Key missing";
            console.log("API Key is missing or is 'demo'. Please configure it.");
            currentPrice = "N/A";
            return;
        }
        if (!localTickerSymbol || localTickerSymbol === "") {
            errorMessage = "Ticker missing";
            console.log("Ticker Symbol is missing. Please configure it.");
            currentPrice = "N/A";
            return;
        }
        
        var xhr = new XMLHttpRequest();
        var url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=" + localTickerSymbol + 
                  "&interval=5min&apikey=" + localApiKey;
                  
        console.log("Fetching URL: " + url);
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("API Response:", JSON.stringify(response));

                        if (response["Error Message"]) {
                            errorMessage = "API Error: " + response["Error Message"];
                            console.error(errorMessage);
                            currentPrice = "Error";
                            return;
                        }
                        if (response["Note"]) {
                            errorMessage = "API Limit Reached? " + response["Note"];
                            console.warn(errorMessage);
                            // Try to continue anyway, might have old data
                        }

                        var timeSeries = response["Time Series (5min)"];
                        if (!timeSeries) {
                            errorMessage = "Unexpected API response format (Missing Time Series)";
                            console.error(errorMessage, JSON.stringify(response));
                            currentPrice = "Error";
                            return;
                        }

                        var latestTime = Object.keys(timeSeries)[0]; // Get the most recent timestamp
                        var latestData = timeSeries[latestTime];
                        if (!latestData || !latestData["4. close"]) {
                            errorMessage = "Unexpected API response format (Missing Latest Data)";
                            console.error(errorMessage, JSON.stringify(latestData));
                            currentPrice = "Error";
                            return;
                        }

                        currentPrice = parseFloat(latestData["4. close"]).toFixed(2);
                        errorMessage = ""; // Clear error on success
                        
                    } catch (e) {
                        errorMessage = "Failed to parse JSON response";
                        console.error(errorMessage, e, xhr.responseText);
                        currentPrice = "Error";
                    }
                } else {
                    errorMessage = "Network Error: " + xhr.status + " " + xhr.statusText;
                    console.error(errorMessage);
                    currentPrice = "Error";
                }
            } else {
                // Optional: Handle other readyStates like LOADING
            }
        }

        // Safely initiate the request
        try {
            xhr.open("GET", url, true);
            xhr.send();
        } catch (e) {
            errorMessage = "Failed to initiate network request";
            console.error(errorMessage, e);
            currentPrice = "Network Error";
        }
    }

    // Timer to refresh data every 5 minutes (300000 ms)
    Timer {
        interval: 15000 // 15 seconds
        running: true
        repeat: true
        onTriggered: fetchStockData()
    }

    // Fetch data when component is ready and when config changes
    Component.onCompleted: {
        fetchStockData();
    }
    Connections {
        target: Plasmoid.configuration
        function onCfg_tickerSymbolChanged() { 
            // Update the root property and then fetch
            try {
                tickerSymbol = Plasmoid.configuration.cfg_tickerSymbol || "IBM"; 
            } catch (e) {
                console.error("Error reading ticker symbol config:", e);
                tickerSymbol = "IBM"; // Fallback
            }
            fetchStockData(); 
        }
        function onCfg_alphaVantageApiKeyChanged() { 
            // Update the root property and then fetch
            try {
                apiKey = Plasmoid.configuration.cfg_alphaVantageApiKey || "demo"; 
            } catch (e) {
                console.error("Error reading API key config:", e);
                apiKey = "demo"; // Fallback
            }
            fetchStockData(); 
        }
    }
    
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
    
    Rectangle {
        id: chartBackground
        width: parent.width - 4
        height: parent.height - 4
        color: PlasmaCore.Theme.backgroundColor
        anchors.centerIn: parent
        border.width: 1
        border.color: PlasmaCore.Theme.textColor
        radius: Math.min(width, height) * 0.2
        
        // Title
        Text {
            id: titleText
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 4
            }
            text: tickerSymbol
            color: PlasmaCore.Theme.textColor
            font.pixelSize: Math.min(parent.width, parent.height) * 0.10
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Display Current Price or Error
        Text {
            id: priceText
            anchors {
                centerIn: parent
            }
            text: errorMessage ? errorMessage : currentPrice
            color: errorMessage ? PlasmaCore.Theme.negativeTextColor : PlasmaCore.Theme.textColor
            font.pixelSize: Math.min(parent.width, parent.height) * 0.25
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        // Chart area
        Item {
            id: chartArea
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 4
            }
            
            // Draw candlesticks
            Repeater {
                model: candleData
                
                Item {
                    id: candle
                    width: chartArea.width / candleData.length
                    height: chartArea.height
                    x: index * width
                    
                    // Use shared constants for clarity
                    readonly property real candleWidthRatio: 0.6 
                    readonly property real wickStrokeWidth: 1
                    
                    property real candleBodyWidth: width * candleWidthRatio
                    property real candleX: (width - candleBodyWidth) / 2
                    property real wickX: candleX + candleBodyWidth / 2

                    // Y positions based on price
                    property real highY: priceToY(modelData.high, chartArea.height)
                    property real lowY: priceToY(modelData.low, chartArea.height)
                    property real openY: priceToY(modelData.open, chartArea.height)
                    property real closeY: priceToY(modelData.close, chartArea.height)
                    
                    // Determine color based on close vs open
                    property color candleColor: modelData.close >= modelData.open ? 
                                              PlasmaCore.Theme.positiveTextColor : 
                                              PlasmaCore.Theme.negativeTextColor

                    // Draw wick (High-Low line)
                    Shape {
                        anchors.fill: parent
                        ShapePath {
                            strokeWidth: candle.wickStrokeWidth
                            strokeColor: candle.candleColor
                            startX: candle.wickX
                            startY: candle.highY
                            PathLine { x: candle.wickX; y: candle.lowY }
                        }
                    }
                    
                    // Draw candle body (Open-Close rectangle)
                    Rectangle {
                        x: candle.candleX
                        y: Math.min(candle.openY, candle.closeY) 
                        width: candle.candleBodyWidth
                        height: Math.abs(candle.openY - candle.closeY)
                        color: candle.candleColor
                    }
                    
                    // Time label
                    Text {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                            margins: 2
                        }
                        text: modelData.time
                        color: PlasmaCore.Theme.textColor
                        font.pixelSize: Math.min(candle.width * 0.3, 10)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}

