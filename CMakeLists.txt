cmake_minimum_required(VERSION 3.16)
project(plasma-stock-widget)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(KF5Plasma REQUIRED)
find_package(KF5I18n REQUIRED)
find_package(KF5Config REQUIRED)

# Set local install directory
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

plasma_install_package(package org.kde.plasma.stockwidget
    SOURCES
        package/contents/code/main.js
        package/contents/ui/main.qml
        package/contents/config/main.xml
        package/metadata.json
) 