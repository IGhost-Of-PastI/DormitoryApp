import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import content

Page {
    id: rectangleMain
    width:1280
    height:320

    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
        text: qsTr("Инфомрация")
    }
    Dialog {
            id: confirmationDialog
            title: "Подтверждение"
            implicitWidth: 400
            implicitHeight: 150
            anchors.centerIn: parent
            contentItem: Column {
                       spacing: 10
                       Text {
                           font.pointSize: 12
                           text: "Вы уверены, что хотите удалить данную запись?"
                           wrapMode: Text.WordWrap
                       }
                   }
            standardButtons: Dialog.Yes | Dialog.No
            onAccepted: {
                var columnValues = tableView.getSelectedRowData();
                var pkcolumn = columnValues.find(function(item) {
                    return pkInfo.columnName === item.columnName;
                });
                var pkvalue= pkcolumn.columnValue;
                var success= MainSQLConnection.deleteRecord(tablename,pkInfo.columnName,pkvalue);
                if (success)
                {
                    aRefresh.trigger();
                    messageDialog.informativeText="Запись удалена успешно!";
                    messageDialog.open();
                }
                else
                {
                    messageDialog.informativeText="При удалении произошла ошибка!";
                    messageDialog.open();
                }
            }
        }

    Action
    {
        id:aAddRecord
        onTriggered:
        {
            if (editorElement.state==="closed")
                                {
                                     editorElement.state="addMode";
                                }

        }
    }
    Action
    {
        id:aEditRecord
        onTriggered:
        {
            if (editorElement.state==="closed")
                                {
                                     editorElement.state="editMode";
                                    var rowData= tableView.getSelectedRowData();
                                    editorElement.columnValues=rowData;
                                   // editorElement.state="editMode"
                                }

        }
    }
    Action
    {
        id:aDeleteRecord
        onTriggered:
        {
            confirmationDialog.open()
        }
    }
    Action
    {

        id:aRefresh
        onTriggered:
        {
                            tableView.refresh();
        }
    }

    property string tablename
    property var columns
    property var pkInfo

    property alias avalAdd:addButton.visible
    property alias avalEdit:editButton.visible
    property alias avalDelete:deleteButton.visible

    onTablenameChanged: {
        var columnsInfo = MainSQLConnection.getColumnsInfo(tablename);
        var pkColumnInfo = columnsInfo.find(function(item) {
            return item.isPK === true;
        });
        columns = columnsInfo;
        pkInfo=pkColumnInfo;
        editorElement.columnInfoList=columnsInfo;
    }

    SplitView
    {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: scrollView.bottom
        orientation: Qt.Horizontal
        Table {
            SplitView.preferredWidth: 500
           SplitView.fillHeight:true
            id: tableView
            clip: true
            tablename: rectangleMain.tablename
        }
        EditorElement {
            id: editorElement
            tablename:rectangleMain.tablename
            state: "closed"
            SplitView.fillHeight:true
            SplitView.preferredWidth: 150
            columnInfoList: MainSQLConnection.getColumnsInfo(tableView.tablename)
            onDataUpdated_Added: (success) => {
                                     if(success)
                                     {
                                         aRefresh.trigger();
                                         messageDialog.informativeText="Данные обновлены успешно!";
                                         messageDialog.open();
                                     }
                                     else
                                     {
                                        messageDialog.informativeText="Произошла ошибка при обновлении данных!";
                                        messageDialog.open();
                                     }
            }

        }
    }

    ScrollView {
        id: scrollView
        height: 48
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0

        ToolBar {
            id: toolBar
            x: 0
            anchors.fill: parent
            width: 1280
            height: 48
            position: ToolBar.Header
            anchors.top: parent.top
            anchors.topMargin: 0

            ToolButton {
                id: addButton
                text: qsTr("Добавить")
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                onClicked: aAddRecord.trigger()
            }

            ToolButton {
                id: editButton
                text: qsTr("Изменить")
                anchors.left: addButton.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                onClicked: aEditRecord.trigger()
            }

            ToolButton {
                id: deleteButton
                text: qsTr("Удалить")
                anchors.left: editButton.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                onClicked: aDeleteRecord.trigger()
            }

            ToolSeparator {
                id: toolSeparator
                anchors.left: deleteButton.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
            }

            Item {
                id: filterItem
                width: 313
                anchors.left: toolSeparator.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0

                Flow {
                    id: flow1
                    x: -546
                    y: 0
                    anchors.left: parent.left
                    anchors.right: optionFilterButton.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                }

                ToolButton {
                    id: optionFilterButton
                    x: 945
                    y: 0
                    text: qsTr("Фильтр")
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                }
            }

            ToolSeparator {
                id: toolSeparator1
                x: 586
                y: 0
                width: 25
                anchors.left: filterItem.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
            }

            ComboBox {
                id: sortColumn
                anchors.left: toolSeparator1.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
            }

            Item {
                id: item1
                width: 300
                anchors.left: sortColumn.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0

                RadioButton {
                    id: descSort
                    width: 140
                    text: qsTr("По убыванию")
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                }

                RadioButton {
                    id: ascSort
                    text: qsTr("По возрастанию")
                    anchors.left: descSort.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                }
            }

            ToolButton {
                id: toolButton
                x: 1141
                text: qsTr("Обновить")
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                onClicked: {
                    aRefresh.trigger();
                }
            }
        }
    }


}
