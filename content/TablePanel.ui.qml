

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls

Rectangle {
    id: rectangleMain
    width: 1280
    height: 720

    TableView {
        id: tableView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: bottomPanel.top
        anchors.topMargin: -48
    }
    Rectangle {
        id: bottomPanel
        width: parent.width
        height: 40
        anchors.bottom: parent.bottom

        CheckBox {
            id: checkBox
            y: 0
            width: 108
            height: parent.height
            text: qsTr("Check Box")
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        Rectangle {
            id: pagesRectangle
            color: "#ffffff"
            anchors.left: checkBox.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

            // visible: checkBox.checked
            Label {
                id: label
                x: 227
                width: contentWidth
                text: qsTr("Страницы:")
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: pagesRectangle.height / 2
            }

            SpinBox {
                id: spinBox
                x: 104
                anchors.right: label.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
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
