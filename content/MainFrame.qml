import QtQuick 6.2
import QtQuick.Controls

Rectangle {
    anchors.fill: parent
    StackView
    {
        id: mainPageContainer

        anchors.fill: parent
        initialItem: loginPage
    }
    LoginFrame
    {
        id:loginPage
        //parentView: mainPageContainer
        onLoginSuccess:
        {

        }
    }
    MainPage
    {
        id:mainPage
    }
}
