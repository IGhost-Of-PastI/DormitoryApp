import QtQuick 6.2
import QtQuick.Controls
import content

Image {
    id: backImage

    anchors.fill: parent
    //source: "file"
    Action
    {
        id: aLogin
        onTriggered:
        {

        }
    }

    Rectangle {
        id: rectangle
        width: 500
        height: 390
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        TextField {
            id: loginField
            width: 443
            height: 56
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.QtRendering
            anchors.verticalCenterOffset: -27
            anchors.horizontalCenterOffset: -7
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Логин")
        }

        TextField {
            id: password
            width: 442
            height: 56
            anchors.verticalCenter: parent.verticalCenter
            echoMode: TextInput.Password
            anchors.verticalCenterOffset: 55
            anchors.horizontalCenterOffset: -4
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Пароль")
        }

        Button {
            id: loginButton
            text: qsTr("Войти")
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 14
            anchors.verticalCenterOffset: 116
            anchors.horizontalCenterOffset: -3
            anchors.horizontalCenter: parent.horizontalCenter
            highlighted: false
            flat: false
            onClicked: aLogin.trigger()
        }

        Label {
            id: label
            text: qsTr("Авторизация")
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 18
            anchors.verticalCenterOffset: -85
            anchors.horizontalCenterOffset: -8
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
