cmake_minimum_required(VERSION 3.21)
project(appAgrocore LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 COMPONENTS Quick REQUIRED)

qt_add_executable(appAgrocore
    main.cpp
)

qt_add_qml_module(appAgrocore
    URI Agrocore
    VERSION 1.0
    QML_FILES
        qml/Agrocore/Main.qml
        QML_FILES qml/Agrocore/DashboardIngeniero.qml
)

target_link_libraries(appAgrocore
    PRIVATE Qt6::Quick
)

set_target_properties(appAgrocore PROPERTIES
    WIN32_EXECUTABLE TRUE
)
