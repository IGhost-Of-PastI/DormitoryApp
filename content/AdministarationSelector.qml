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

    Action
    {
        id: aBackupsPage
        onTriggered: {
            mainPageLoader.sourceComponent=backupsComponent;
            stackView.push(mainPageLoader.item);
        }
    }
    Action
    {
        id:aFreeQueries
        onTriggered:
        {
            mainPageLoader.sourceComponent=freeQueryComponent;
            stackView.push(mainPageLoader.item);
        }
    }
    Action
    {
        id: aLogs
        onTriggered:
        {
            mainPageLoader.sourceComponent=logsComponent;
            stackView.push(mainPageLoader.item);
        }
    }
    Action
    {
        id:aReports
        onTriggered:
        {
            //mainPageLoader.sourceComponent=Component;
            //stackView.push(mainPageLoader.item);
        }
    }
    Component
    {
        id:freeQueryComponent
        FreeQueriesPage
        {
            onRequestPop: {
                           stackView.pop();
                       }
        }
    }
    Component
    {
        id:backupsComponent
        BackupsPage
        {
            onRequestPop: {
                           stackView.pop();
                       }
        }
    }
    /*Component
    {
        id:reportsComponent
        Re
    }*/
    Component
    {
        id:logsComponent
        LogsViewPage
        {
            onRequestPop: {
                           stackView.pop();
                       }
        }
    }

    Loader {
        id: mainPageLoader
        visible: false
    }

    StackView {
        anchors.fill: parent
        id:stackView
        initialItem: selector
    }

    Component
    {
        id:selector
        Column {
            id: column
            anchors.fill: parent
            clip: false
            spacing: 5

            Button {
                id: viewLogsButton
                text: qsTr("Просмотр логов")
                onClicked: aLogs.trigger()
            }

            Button {
                id: configureBackupsButton
                text: qsTr("Управление бэкапами")
                onClicked: aBackupsPage.trigger();
            }

            Button {
                id: reportButton
                text: qsTr("Отчёты")
                onClicked: aReports.trigger()
            }

            Button {
                id: freeQueryButton
                text: qsTr("Произвольные запросы")
                onClicked: aFreeQueries.trigger();
            }

           /* Button {
                id: configureUser
                text: qsTr("Настройка пользваотеля")
            }*/
        }
    }

}
