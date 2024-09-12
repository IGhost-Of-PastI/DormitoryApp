import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: administrationSelector
    property var userinfo
    onUserinfoChanged:
    {
        var Accesses = JSON.parse(userinfo.acceses);
        var UserAccesses = JSON.parse(Accesses.valueOf("UserAccesses"));
      viewLogsButton.visible= UserAccesses.valueOf("ViewLogs");
      configureBackupsButton.visible=  UserAccesses.valueOf("ConfigureBackups");
      reportButton.visible=UserAccesses.valueOf("Reports");
      freeQueryButton.visible= UserAccesses.valueOf("FreeQueries");
      configureUser.visible= UserAccesses.valueOf("ConfigureUser");
    }

    StackView {
        width: 1920
        height: 1080

        Column {
            id: column
            anchors.fill: parent
            clip: false
            spacing: 5

            Button {
                id: viewLogsButton
                text: qsTr("Просмотр логов")
                highlighted: false
            }

            Button {
                id: configureBackupsButton
                text: qsTr("Управление бэкапами")
            }

            Button {
                id: reportButton
                text: qsTr("Отчёты")
            }

            Button {
                id: freeQueryButton
                text: qsTr("Произвольные запросы")
            }

            Button {
                id: configureUser
                text: qsTr("Настройка пользваотеля")
            }
        }
    }
}
