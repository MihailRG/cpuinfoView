import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item {
    width: 800
    height: 800

    property alias button1: button1
    property alias button2: button2

    RowLayout {
        x: 800
        y: 800
        anchors.verticalCenterOffset: 214
        anchors.horizontalCenterOffset: -304
        anchors.centerIn: parent

        Button {
            id: button1
            text: qsTr("CHECK")
        }

        Button {
            id: button2
            text: qsTr("RESULTS")
        }
    }
}
