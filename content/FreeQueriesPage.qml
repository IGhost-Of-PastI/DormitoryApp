import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import content

Rectangle {
    id: rectangle
    width: 1920
    height: 1080

    signal requestPop()

    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
        text: qsTr("Инфомрация")
    }

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
           var result= tableModel.setTableQuery(textField.text);
            //queryResults.forceLayout();
            if(result !== "")
            {
                messageDialog.text="Ошибка "+result;
                messageDialog.open();
            }
        }
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height:150

        Row
        {
            ToolButton {
                id: toolButton1
                text: qsTr("Назад")
                onClicked: aGoBack.trigger()
            }


            TextArea {
                id: textField
                width:500
                placeholderText: qsTr("Запрос")
            }

            ToolButton {
                id: toolButton
                text: qsTr("Выполнить")
                onClicked: aExecQuery.trigger()
            }
        }

    }
    TableView
    {
        id:queryResults
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        model: QueryTableModel
        {
            id:tableModel
         //   tablename:"logs"
        }

    }
}
