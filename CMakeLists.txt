cmake_minimum_required(VERSION 3.16)
project(plasma-stock-widget)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(KF5Plasma REQUIRED)
find_package(KF5I18n REQUIRED)
find_package(KF5Config REQUIRED)

plasma_install_package(package org.kde.plasma.stockwidget
    SOURCES
        contents/code/main.js
        contents/ui/main.qml
        contents/config/main.xml
        metadata.desktop
) 