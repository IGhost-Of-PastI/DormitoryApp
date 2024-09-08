import QtQuick 6.2
import QtQuick.Controls

Rectangle {
    anchors.fill: parent
    StackView
    {
        id: mainPageContainer

        anchors.fill: parent
        initialItem: "LoginFrame.qml"
    }

}
