import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Dialogs
import "."

Rectangle {
    id: backImage
    signal loginedSuc(var userinfo)
    //property UserInfo userinfo;


    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
        text: qsTr("Инфомрация")
        informativeText: qsTr("Неверный логин или пароль!")
    }
    Action
    {
        id: aLogin


        /*MessageDialog {
               id: messageDialog
               title: "Внимание"
               text: "Неверный логин или пароль!"
              // icon: StandardIcon.Information
               buttons: Qt.Ok
               //standardButtons: StandardButton.Ok
           }*/


        onTriggered:
        {
            var vuserinfo = MainSQLConnection.autorize(loginField.text,password.text);
            if (vuserinfo.isAutorized)
            {
                loginedSuc(vuserinfo);
                messageDialog.text=vuserinfo.acceses;
                messageDialog.open();
                password.text="";
            }
            else
            {
                messageDialog.open();
            }

            //parentView.push({item:"MainPage.qml", properties:{userinfo:vuserinfo}})

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
