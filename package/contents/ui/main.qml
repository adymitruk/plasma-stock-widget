import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    // Add settings button to the widget
    Plasmoid.toolTipMainText: "Stock Widget"
    Plasmoid.toolTipSubText: "Click to configure"
    
    // Add configuration dialog
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Configure"
            icon.name: "configure"
            onTriggered: configDialog.open()
        }
    ]
    
    // Configuration dialog
    PlasmaCore.Dialog {
        id: configDialog
        visualParent: root
        title: "Stock Widget Settings"
        location: PlasmaCore.Types.DialogLocation.Center
        type: PlasmaCore.Dialog.Dialog
        flags: Qt.WindowStaysOnTopHint
        
        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.smallSpacing
            
            PlasmaComponents3.Label {
                text: "Alpha Vantage API Key:"
            }
            
            PlasmaComponents3.TextField {
                id: apiKeyInput
                Layout.fillWidth: true
                echoMode: TextInput.Password
                text: plasmoid.configuration.apiKey
                onTextChanged: {
                    plasmoid.configuration.apiKey = text
                }
            }
            
            PlasmaComponents3.Button {
                text: "Close"
                Layout.alignment: Qt.AlignRight
                onClicked: configDialog.close()
            }
        }
    }
    
    // Message view for errors and status
    fullRepresentation: Item {
        Layout.minimumWidth: 200
        Layout.minimumHeight: 100
        
        // Stack view to switch between main and message views
        StackLayout {
            id: stackLayout
            anchors.fill: parent
            currentIndex: stockWidget.state === "error" ? 1 : 0
            
            // Main view
            ColumnLayout {
                spacing: 5
                
                PlasmaComponents3.TextField {
                    id: symbolInput
                    placeholderText: "Enter stock symbol"
                    Layout.fillWidth: true
                    onTextChanged: {
                        if (text.length >= 1) {
                            stockWidget.updateStock(text)
                        }
                    }
                }
                
                PlasmaComponents3.Label {
                    id: stockPrice
                    text: "Loading..."
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                
                PlasmaComponents3.Label {
                    id: stockChange
                    text: ""
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // Message view
            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                
                PlasmaCore.IconItem {
                    id: messageIcon
                    Layout.alignment: Qt.AlignHCenter
                    source: stockWidget.state === "error" ? "dialog-error" : "dialog-information"
                    width: 32
                    height: 32
                }
                
                PlasmaComponents3.Label {
                    id: messageText
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: stockWidget.message
                }
                
                PlasmaComponents3.Button {
                    text: "Configure"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: configDialog.open()
                    visible: stockWidget.state === "error" && !plasmoid.configuration.apiKey
                }
            }
        }
    }
} 