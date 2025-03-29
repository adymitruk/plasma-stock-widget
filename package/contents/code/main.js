const stockWidget = {
    state: "idle",
    message: "",
    logFile: null,
    
    init: function() {
        // Initialize logging
        const logDir = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation) + "/plasma-stock-widget";
        const logPath = logDir + "/stock-widget.log";
        
        // Create log directory if it doesn't exist
        const dir = new QDir(logDir);
        if (!dir.exists()) {
            dir.mkpath(".");
        }
        
        // Open log file
        this.logFile = new QFile(logPath);
        this.logFile.open(QIODevice.Append | QIODevice.Text);
        
        this.log("Widget initialized");
    },
    
    log: function(message) {
        if (!this.logFile) return;
        
        const timestamp = new Date().toISOString();
        const logMessage = `[${timestamp}] ${message}\n`;
        this.logFile.write(logMessage);
        this.logFile.flush();
    },
    
    updateStock: function(symbol) {
        const apiKey = plasmoid.configuration.apiKey;
        
        this.log(`Updating stock for symbol: ${symbol}`);
        
        if (!apiKey) {
            this.state = "error";
            this.message = "Please set your Alpha Vantage API key in the widget settings.";
            this.log("Error: API key not set");
            return;
        }
        
        this.state = "loading";
        this.message = "Loading stock data...";
        this.log("Fetching stock data...");
        
        const url = `https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${symbol}&apikey=${apiKey}`;
        
        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                if (data['Global Quote']) {
                    const quote = data['Global Quote'];
                    const price = parseFloat(quote['05. price']).toFixed(2);
                    const change = parseFloat(quote['09. change']).toFixed(2);
                    const changePercent = parseFloat(quote['10. change percent']).toFixed(2);
                    
                    // Update the UI
                    stockPrice.text = `$${price}`;
                    stockChange.text = `${change >= 0 ? '+' : ''}${change} (${changePercent}%)`;
                    stockChange.color = change >= 0 ? '#00ff00' : '#ff0000';
                    
                    this.state = "idle";
                    this.message = "";
                    this.log(`Stock data updated - Price: $${price}, Change: ${change} (${changePercent}%)`);
                } else {
                    this.state = "error";
                    this.message = "Invalid stock symbol. Please check and try again.";
                    this.log(`Error: Invalid stock symbol - ${symbol}`);
                }
            })
            .catch(error => {
                this.state = "error";
                if (error.message.includes("HTTP error")) {
                    this.message = "Failed to connect to the stock service. Please check your internet connection.";
                    this.log(`Error: HTTP error - ${error.message}`);
                } else {
                    this.message = "An error occurred while fetching stock data. Please try again later.";
                    this.log(`Error: ${error.message}`);
                }
            });
    }
};

// Initialize the widget when the script loads
stockWidget.init(); 