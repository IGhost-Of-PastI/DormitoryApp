import QtQuick 2.15
import QtQuick.Controls 2.15
import content

Rectangle {
    id: rectangle
    width: 1920
    height: 1080

    property UserInfo userinfo;

    ToolBar {
        id: toolBar
        width: 100
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        ToolButton {
            id: toolButton
            text: qsTr("Профиль")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: toolButton2.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
        }

        ToolButton {
            id: toolButton1
            y: 813
            text: qsTr("Выйти")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
        }

        ToolButton {
            id: toolButton2
            text: qsTr("Открыть")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            onClicked: menu.opened() ? menu.close() : menu.open()
        }


    }
    Drawer
    {
        id:menu
        edge:Qt.LeftEdge
        x:toolBar.width
        width: 0.25 * window.width
        height: parent.height
        visible: true
       // opened:true
        ListView
        {
            id: tables
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

        }
    }

    SwipeView
    {
        anchors.left: toolBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        orientation: Qt.Vertical
    }


}
