/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: item2
    width: 1920
    height: 1080

    Item {
        id: item1
        height: 83
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0

        TextField {
            id: textField
            x: 62
            y: 19
            width: 530
            height: 56
            placeholderText: qsTr("Главная директория бэкапов")
        }

        Button {
            id: button
            x: 670
            y: 19
            text: qsTr("Открыть")
        }
    }

    TableView
    {
        anchors.fill: parent
        anchors.topMargin: 587

    }

    Button {
        id: button1
        x: 459
        y: 471
        text: qsTr("Сохрнаить")
    }

    Button {
        id: button2
        x: 649
        y: 479
        text: qsTr("Сброс")
    }

    SpinBox {
        id: spinBox
        x: 513
        y: 200
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0

        ToolButton {
            id: toolButton1
            x: 265
            y: -222
            text: qsTr("Открыть")
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }

        ToolButton {
            id: toolButton
            x: 0
            y: -222
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }
    }

    ToolBar {
        id: toolBar1
        x: 881
        y: 340
        width: 360

        ToolButton {
            id: toolButton2
            x: 0
            y: 0
            text: qsTr("Сделать бэкап")
        }
    }

    ToolButton {
        id: toolButton3
        x: 967
        y: 340
        text: qsTr("Tool Button")
    }

    ToolButton {
        id: toolButton4
        x: 1059
        y: 340
        text: qsTr("Tool Button")
    }
}
