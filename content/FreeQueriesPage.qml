import QtQuick
import QtQuick.Controls
import content

Rectangle {
    id: rectangle
    width: 1920
    height: 1080

    signal requestPop()

    Action
    {
        id:aGoBack
        onTriggered:
        {
            requestPop();
        }
    }

    Action
    {
        id:aExecQuery
        onTriggered:
        {

        }
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        height:150


        TextArea {
            id: textField
            anchors.left: toolButton1.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            width:500
            placeholderText: qsTr("Запрос")
        }

        ToolButton {
            id: toolButton
            text: qsTr("Выполнить")
            anchors.left: textField.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            onClicked: aExecQuery
        }

        ToolButton {
            id: toolButton1
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.topMargin: 0
            onClicked: aGoBack.trigger()
        }
    }
    TableView
    {
        id:queryResults
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        model: TableModel
        {

        }

    }
}
