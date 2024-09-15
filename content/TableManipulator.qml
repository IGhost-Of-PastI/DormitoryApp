import QtQuick 2.15
import QtQuick.Controls
import content

Page {
    id: rectangleMain
    width:1280
    height:720
   // clip:true
    //anchors.fill: parent
   // property string tablename;
   // property bool isAdd;
   // property bool isEdit;
   // property bool isDelete;
    Action
    {
        id:aAddRecord;
        onTriggered:
        {
            if (editorElement.visible === false)
            {
                editorElement.visible=true;
            }
        }
    }



    property alias tablename:tableView.tablename
    property alias avalAdd:addButton.visible
    property alias avalEdit:editButton.visible
    property alias avalDelete:deleteButton.visible

    SplitView
    {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: scrollView.bottom
        //anchors.fill:parent
       // color:"blue"
        orientation: Qt.Horizontal
        Table {
            SplitView.preferredWidth: 500
           SplitView.fillHeight:true
            id: tableView
           // model: MainSQLConnection.getRelatioanlTableModel(tablename);
           // anchors.left: parent.left
           // anchors.right: parent.right
           // anchors.top: scrollView.bottom
           // anchors.bottom: parent.top
        }
        EditorElement {
            id: editorElement
            SplitView.fillHeight:true
            SplitView.preferredWidth: 150
            columnInfoList: MainSQLConnection.getColumnsInfo(tableView.tablename)
           // visible: false
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
            }
        }
    }


}
