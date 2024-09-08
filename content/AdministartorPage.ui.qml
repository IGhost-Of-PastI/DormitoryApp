

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

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
