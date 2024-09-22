import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: administrationSelector
    property var tableaccJson
    onTableaccJsonChanged: {
        viewLogsButton.visible = tableaccJson.ViewLogs
        configureBackupsButton.visible = tableaccJson.ConfigureBackups
        reportButton.visible = tableaccJson.Reports
    }

    Action {
        id: aBackupsPage
        onTriggered: {
            mainPageLoader.sourceComponent = backupsComponent
            stackView.push(mainPageLoader.item)
        }
    }
    Action {
        id: aLogs
        onTriggered: {
            mainPageLoader.sourceComponent = logsComponent
            stackView.push(mainPageLoader.item)
        }
    }
    Action {
        id: aReports
        onTriggered: {
            mainPageLoader.sourceComponent = reportsComponent
            stackView.push(mainPageLoader.item)
            //mainPageLoader.sourceComponent=Component;
            //stackView.push(mainPageLoader.item);
        }
    }
    Component {
        id: backupsComponent
        BackupsPage {
            onRequestPop: {
                stackView.pop()
            }
        }
    }
    Component {
        id: reportsComponent
        ReportPage {}
    }
    Component {
        id: logsComponent
        LogsViewPage {
            onRequestPop: {
                stackView.pop()
            }
        }
    }

    Loader {
        id: mainPageLoader
        visible: false
    }

    StackView {
        anchors.fill: parent
        id: stackView
        initialItem: column
    }

    // Component
    // {
    //    id:selector
    Column {
        id: column
        //    anchors.fill: parent
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
            onClicked: aBackupsPage.trigger()
        }

        Button {
            id: reportButton
            text: qsTr("Отчёты")
            onClicked: aReports.trigger()
        }


        /* Button {
                id: configureUser
                text: qsTr("Настройка пользваотеля")
            }*/
    }
    //}
}
