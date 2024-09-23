import QtQuick 6.2
import QtQuick.Controls
import "."

//import content
Rectangle {
    anchors.fill: parent
    StackView {
        id: mainPageContainer

        anchors.fill: parent
        initialItem: loginPage
    }

    LoginFrame {
        id: loginPage
        onLoginedSuc: userinfo => {
                          mainPageLoader.sourceComponent = mainPageComponent
                          mainPageLoader.item.userinfo = userinfo
                          mainPageContainer.push(mainPageLoader.item)
                      }
    }

    Loader {
        id: mainPageLoader
        visible: false
    }

    Component {
        id: mainPageComponent
        MainPage {
            id: mainPage
        }
    }
}
