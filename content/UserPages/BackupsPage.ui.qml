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
            placeholderText: qsTr("Text Field")
        }

        Button {
            id: button
            x: 670
            y: 19
            text: qsTr("Button")
        }
    }

    TableView
    {
        anchors.fill: parent

    }
}
