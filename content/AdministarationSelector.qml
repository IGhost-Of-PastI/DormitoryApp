import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: administrationSelector
    property var userinfo
    onUserinfoChanged:
    {
       // var JsonString=JSON.stringify(userinfo.acceses);
        var Accesses = JSON.parse(userinfo.acceses);
        var UserAccesses = Accesses.UserAccesses;
      viewLogsButton.visible= UserAccesses.ViewLogs;
      configureBackupsButton.visible=  UserAccesses.ConfigureBackups;
      reportButton.visible=UserAccesses.Reports;
      freeQueryButton.visible= UserAccesses.FreeQueries;
      configureUser.visible= UserAccesses.ConfigureUser;
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
