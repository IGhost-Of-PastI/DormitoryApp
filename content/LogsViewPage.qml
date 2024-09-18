import QtQuick 2.15
import QtQuick.Controls 2.15
//import Qt.labs.calendar

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

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height:100
        TextField
        {
            id:fieldSearch
            anchors.left: goBack.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            placeholderText: "Ввод фильтра";
        }
        ComboBox
        {
            id:searchColumnCB
            model:searchModel
            anchors.left: fieldSearch.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        ToolButton {
            id: optionFilterButton
            text: qsTr("Фильтр")
            anchors.left: searchColumnCB.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked:
            {
                aAcceptAllFilters.trigger();
            }
        }
        ToolSeparator {
            id: toolSeparator1
            width: 25
            anchors.left: optionFilterButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        ComboBox {
            id: sortColumn
            model:sortModel
            anchors.left: toolSeparator1.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        Item {
            id: item1
            width: 300
            anchors.left: sortColumn.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            RadioButton {
                id: descSort
                width: 140
                text: qsTr("По убыванию")
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }

            RadioButton {
                id: ascSort
                text: qsTr("По возрастанию")
                anchors.left: descSort.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                checked: true
            }
        }

        GroupBox {
            id: groupBox
            y: 7
            width: 291
            height: 86
            anchors.left: item1.right
            anchors.leftMargin: 0
            title: qsTr("Выборка по дате:")

            CheckBox {
                id: checkBox
                x: 146
                y: -19
                text: qsTr("Использовать")
            }

            SpinBox {
                id: hours
                x: 78
                y: 18
                height:30
                width:100

                from: 0
                to:23
            }

            SpinBox {
                id: minutes
                x: 184
                y: 18
                height:30
                width:100

                from:0
                to:59
            }

            SpinBox {
                id: hours1
                x: 78
                y: 54

                width:100
                height:30

                to: 23
                from: 0
            }

            SpinBox {
                id: minutes1
                x: 184
                y: 54

                width:100
                height:30

                to: 59
                from: 0
            }
        }

        ToolButton {
            id: toolButton
            x: 1141
            text: qsTr("Обновить")
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked: {
                aRefresh.trigger();
            }
        }



        ToolSeparator {
            id: toolSeparator
            anchors.left: sortOrder.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }

        ToolSeparator {
            id: toolSeparator2
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }

        ToolButton {
            id: goBack
            width: 121
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            onClicked: aGoBack.trigger()
        }
    }

    SplitView
    {
        orientation: Qt.Vertical
        id:tableSplit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: -3
        Rectangle
        {
            id: rectangle1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            SplitView.preferredHeight: 500

            Label
            {
                text: "Список логов"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignHCenter
                height:40
            }

            TableView
            {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.rightMargin: 1920
                anchors.topMargin: 0

            }
        }
        Rectangle
        {
            id: rectangle2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            SplitView.preferredHeight: 500

            Label
            {
                text: "Информация из конкретного лога"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignHCenter
                height:40
            }

            TableView
            {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.rightMargin: 1920
                anchors.topMargin: 0

            }
        }
    }


}
