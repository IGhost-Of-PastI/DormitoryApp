import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings
import QtQuick.Dialogs
import Qt.labs.folderlistmodel
import content

Item {
    id: item1

    BackupActions
    {
        id: backupActions
    }

    states: [
        State {
            name: "NoChanges"
            PropertyChanges { target: border; color:defaultProperty
            }
        },
        State {
            name: "SomethingChanged"
            PropertyChanges {
                target: border; color:"red"
            }
        }
    ]

    signal requestPop()

    Action
    {
        id:aSaveBackupSettings
        onTriggered:
        {
            var date=new Date();
            date.setHours(hours.value);
            date.setMinutes(minutes.value);
            date.setSeconds(0);
            backupSettings.path=backupFolderPath.text;
            backupSettings.shedule=howOften.value;
            backupSettings.startTime=date.toTimeString();
            //backupSettings.startTime=hours.value+":"+minutes.value;
            backupSettings.sync()
            backupFolderPath.state="NoChanges"
            howOften.state="NoChanges"
        }
    }
    Action
    {
        id:aResetSettings
        onTriggered:
        {
            backupFolderPath.text=backupSettings.path
            howOften.value=backupSettings.shedule
            backupFolderPath.state="NoChanges"
            howOften.value="NoChanges"
        }
    }

    Action
    {
        id:aGoBack
        onTriggered:
        {
            requestPop()
            stackView.pop()
        }
    }
    Action
    {
        id:aDoBackup
        onTriggered:
        {
            backupActions.doBackup();
        }
    }
    Action
    {
        id:aDeleteBackupFile
        onTriggered:
        {

        }
    }
    Action
    {
        id:aSetBackupTask
        onTriggered:
        {
            backupActions.setTaskToBackup()
        }
    }
    Action
    {
        id:aDeleteTask
        onTriggered:
        {
            backupActions.deleteTaskToBackup()
        }
    }

    Settings
    {
        id:databaseInfo
        category: "DatabaseInfo"
        fileName: "settings.ini"
        property string user : "postgres"
        property string password:"masterkey"
        property string host:"localhost"
        property int port:5432
        property string database:"Dormitory"
    }

    Settings
    {
        id:backupSettings
        category: "BackupSection"
        fileName: "settings.ini"
        property string path
        property int shedule
        property string startTime
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        ToolButton {
            id: goBackButton
            x: 0
            y: -222
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked: aGoBack.trigger()
        }
    }

    SplitView
    {
        id: splitView
        orientation: Qt.Vertical
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom:parent.bottom
        anchors.top: toolBar.bottom
        clip: true
        // visible: false

        Column
        {
            anchors.topMargin: 20
            spacing: 10
            id: optionsPanel
            clip: true
            //  height: splitView.height/2
            SplitView.preferredHeight: 500//splitView.height/2
            SplitView.fillWidth: true
            //  anchors.right: parent.right
            // anchors.left:parent.left

            //Folder editor
            Row
            {
                x:20
                anchors.topMargin: 20
                spacing: 10
                TextField {
                    id: backupFolderPath
                    width: 530
                    height: 56
                    readOnly: true
                    text: backupSettings.path
                    placeholderText: qsTr("Главная директория бэкапов")
                }

                Button {
                    id: openPath
                    text: qsTr("Открыть")
                    onClicked: folderDialog.open();
                    FolderDialog
                    {
                        id:folderDialog

                        currentFolder: backupFolderPath.text;
                        onAccepted:
                        {
                            backupFolderPath.text= AdditionalFunctions.uriToFileSysPath(currentFolder);

                            //var path = currentFolder
                            //path.substrign
                                    // Убираем префикс file:///
                            // path = path.substring(8);
                                    // Декодируем URL
                            //        path = decodeURIComponent(path)
                            //        backupFolderPath.text = path
                        }
                    }
                }
            }

            Row
            {
                x:20
                spacing: 10
                Label {
                    id: label
                    text: qsTr("Раз во сколько дней:")
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 16
                    //anchors.verticalCenter: parent
                }
                SpinBox {
                    id: howOften
                    value: backupSettings.shedule
                    from: 1
                }
            }



            Row
            {
                x:20
                spacing: 10

                Label {
                    id: startTime
                    text: qsTr("Восколькуо начинать:")
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 16
                }

                SpinBox {
                    id: hours
                    from: 0
                    to:23
                }

                SpinBox {
                    id: minutes
                    from:0
                    to:59
                }
            }
            Row
            {
                x:20
                spacing: 10
                Button {
                    id: saveBackupSettingsButton
                    text: qsTr("Сохрнаить")
                    onClicked: aSaveBackupSettings.trigger()
                }

                Button {
                    id: restoreBackupSettings
                    text: qsTr("Сброс")
                    onClicked: aResetSettings

                }
            }
        }
        Rectangle
        {
            id: rectangle
            SplitView.preferredHeight: splitView.height/2
            SplitView.fillWidth: true

            clip: true
            ToolBar {
                id: toolBar1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                clip: true

                ToolButton {
                    id: doBackupButton
                    text: qsTr("Сделать бэкап")
                    onClicked: aDoBackup.trigger()
                }
                ToolButton {
                    id: deleteBackupFileButton
                    text: qsTr("Удалить бэкап")
                    anchors.left: doBackupButton.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    onClicked: aDeleteBackupFile.trigger()
                }
                Row
                {
                    anchors.top: parent
                    anchors.bottom: parent
                    anchors.left: deleteBackupFileButton.right
                    ToolButton {
                        id: setBackupTaskButton
                        height: parent.height
                        text: qsTr("Установить задачу на бэкапы")
                        onClicked: aSetBackupTask.trigger()
                    }
                    ToolButton {
                        id: deleteBackupTaskButton
                        text: qsTr("Удалить задачу на бэкапы")
                        anchors.left: deleteBackupFileButton.right
                        onClicked: aDeleteTask.trigger()
                    }
                    Label {
                        id: taskStatus
                        property bool isActived:backupActions.isTaskActive;
                        onIsActivedChanged:
                        {
                          if (isActived)
                          {
                             text="Задача активана";
                              color="green";
                          }
                          else
                          {
                              text="Задача не активна";
                              color="red";
                          }
                        }
                        text: qsTr("Задача бэкапа:")
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 16
                    }
                }
            }


            ListView
            {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: toolBar1.bottom
                anchors.bottom: parent.bottom
                highlight: Rectangle { color: "lightblue";radius: 5}
                //highlightFollowsCurrentItem: true
                clip: true

                FolderListModel
                {
                    id:folderModel
                    folder: backupSettings.path
                   // showFiles: true
                    showDirs: false
                    nameFilters: ["*.sql"]
                }


                model:folderModel
                delegate: Item
                {
                    //id: listDelegate
                    width: parent.width
                    height: 40

                    required property string fileName
                    required property date fileModified
                    Row
                    {
                        Text {
                            text: fileName
                        }
                        Text {
                            text: fileModified.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss")
                        }
                    }
                }
            }
        }
    }
}
