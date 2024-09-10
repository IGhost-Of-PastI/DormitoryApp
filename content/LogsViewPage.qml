import QtQuick 2.15
import QtQuick.Controls 2.15
//import Qt.labs.calendar

Rectangle {
    id: rectangle
    width: 1920
    height: 1080

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        height:100
        ComboBox {
            id: sortColumn
            width:200
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
        }

        ComboBox {
            id: sortOrder
            width:200
            anchors.left: sortColumn.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
        }

        ListView {
            id: listView
            width: 300
            anchors.left: toolSeparator.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: -6
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            model: ListModel {
                ListElement {
                    name: "Grey"
                    colorCode: "grey"
                }

                ListElement {
                    name: "Red"
                    colorCode: "red"
                }

                ListElement {
                    name: "Blue"
                    colorCode: "blue"
                }

                ListElement {
                    name: "Green"
                    colorCode: "green"
                }
            }
            delegate: Item {
                x: 5
                width: 80
                height: 40
                Row {
                    id: row1
                    spacing: 10
                    Rectangle {
                        width: 40
                        height: 40
                        color: colorCode
                    }

                    Text {
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                    }
                }
            }
        }

        ToolButton {
            id: toolButton
            text: qsTr("Tool Button")
            anchors.left: listView.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
        }

        GroupBox {
            id: groupBox
            y: 7
            width: 291
            height: 86
            anchors.left: toolSeparator1.right
            anchors.leftMargin: 5
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
            id: toolSeparator1
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 0
            anchors.bottomMargin: 0
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
