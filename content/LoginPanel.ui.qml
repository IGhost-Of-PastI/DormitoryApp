

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: rectangle
    width: 500
    height: 500

    TextField {
        id: loginField
        width: 443
        height: 56
        anchors.verticalCenter: parent.verticalCenter
        renderType: Text.QtRendering
        anchors.verticalCenterOffset: -138
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Логин")
    }

    TextField {
        id: password
        width: 442
        height: 56
        anchors.verticalCenter: parent.verticalCenter
        echoMode: TextInput.Password
        anchors.verticalCenterOffset: -52
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Пароль")
    }

    Button {
        id: loginButton
        text: qsTr("Войти")
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 14
        anchors.verticalCenterOffset: 38
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        highlighted: false
        flat: false
    }

    Label {
        id: label
        text: qsTr("Авторизация")
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 18
        anchors.verticalCenterOffset: -205
        anchors.horizontalCenterOffset: 2
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
