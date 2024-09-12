import QtQuick 6.2
import QtQuick.Controls
import "."
//import content

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
        onLoginedSuc:(userinfo) =>
                     {
                         mainPageContainer.push(mainPage);
                         mainPage.visible=true;
                         mainPage.userinfo=userinfo;
                     }


       // loginedSuc:
       // {
       //     mainPageContainer.push(mainPage);
       //     mainPage.visible=true;
       //     mainPage.userinfo=auserinfo;
       // }

        //parentView: mainPageContainer
    }

    MainPage
    {
        id:mainPage
        visible: false
    }
}
