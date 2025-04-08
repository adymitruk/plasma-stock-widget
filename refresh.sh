#!/bin/bash

# Refresh the stock ticker widget

# update the version info with the current date and time of installation
sed -i "s/version: .*/version: $(date +%Y%m%d%H%M%S)/" com.dymitruk.stockticker/metadata.json

# upgrade the plasmoid 
kpackagetool5 --type=Plasma/Applet --upgrade com.dymitruk.stockticker

# restart the plasma shell
plasmashell --replace &

#
