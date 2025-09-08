import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Page {
    id: root
    anchors.fill: parent
    background: Rectangle { color: "#0d1117" } // fondo oscuro

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // ---- KPIs ----
        RowLayout {
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#161b22"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: "Sensores online: 28"
                    color: "white"
                    font.pixelSize: 20
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#161b22"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: "Sensores offline: 4"
                    color: "white"
                    font.pixelSize: 20
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#161b22"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: "Lecturas/hora: 1920"
                    color: "white"
                    font.pixelSize: 20
                }
            }
        }

        // ---- Alertas críticas ----
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: "#161b22"
            radius: 12

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Text { text: "Alertas críticas"; color: "orange"; font.bold: true }
                Text { text: "• Sensor offline - S-014"; color: "red" }
                Text { text: "• Temperatura alta - Invernadero 2"; color: "red" }
            }
        }

        // ---- Gráficas rápidas ----
        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Humedad
            ChartView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                antialiasing: true
                backgroundColor: "#161b22"

                ValueAxis { id: axisX; min: 0; max: 24; titleText: "Horas" }
                ValueAxis { id: axisY; min: 0; max: 100; titleText: "Humedad %" }

                LineSeries {
                    axisX: axisX
                    axisY: axisY
                    color: "deepskyblue"
                    points: [
                        { x: 0, y: 60 }, { x: 6, y: 65 }, { x: 12, y: 70 },
                        { x: 18, y: 62 }, { x: 24, y: 64 }
                    ]
                }
            }

            // Temperatura
            ChartView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                antialiasing: true
                backgroundColor: "#161b22"

                ValueAxis { id: axisX2; min: 0; max: 24; titleText: "Horas" }
                ValueAxis { id: axisY2; min: 0; max: 50; titleText: "Temp °C" }

                LineSeries {
                    axisX: axisX2
                    axisY: axisY2
                    color: "tomato"
                    points: [
                        { x: 0, y: 22 }, { x: 6, y: 25 }, { x: 12, y: 31 },
                        { x: 18, y: 28 }, { x: 24, y: 26 }
                    ]
                }
            }
        }
    }
}
