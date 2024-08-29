

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
        id: tableQuery
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: bottomPanel.top
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
}
