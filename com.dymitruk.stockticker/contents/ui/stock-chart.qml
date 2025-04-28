import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Shapes 1.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    property string displayName: Plasmoid.configuration.cfg_displayName || "Stock"
    
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
            text: displayName
            color: PlasmaCore.Theme.textColor
            font.pixelSize: Math.min(parent.width, parent.height) * 0.15
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Chart area
        Item {
            id: chartArea
            anchors {
                top: titleText.bottom
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

