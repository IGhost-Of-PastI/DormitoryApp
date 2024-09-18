import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings
import QtQuick.Dialogs
import Qt.labs.folderlistmodel

Item {
    id: item1
    width: 1920
    height: 1080

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
            backupSettings.path=backupFolderPath.text
            backupSettings.shedule=howOften.value
            backupSettings.sync()
            backupFolderPath.state="NoChanges"
            howOften.value="NoChanges"
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

        }
    }
    Action
    {
        id:aDeleteBackupFile
        onTriggered:
        {

        }
    }

    Settings
    {
        id:databaseInfo
        category: "DatabaseInfo"
        fileName: "settings.ini"
        property string user
        property string password
        property string host
        property int port
        property string database
    }

    Settings
    {
        id:backupSettings
        category: "BackupSection"
        fileName: "settings.ini"
        property string path
        property int shedule
        property date startTime
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0

        ToolButton {
            id: toolButton1
            x: 265
            y: -222
            text: qsTr("Открыть")
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            visible: false
            // onClicked: backupOptions.open()
        }

        ToolButton {
            id: goBackButton
            x: 0
            y: -222
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
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


        Rectangle
        {
            id: optionsPanel
            clip: true
            //  height: splitView.height/2
            SplitView.preferredHeight: 500//splitView.height/2
            SplitView.fillWidth: true
            //  anchors.right: parent.right
            // anchors.left:parent.left

            //Folder editor
            TextField {
                id: backupFolderPath
                x: 62
                y: 19
                width: 530
                height: 56
                readOnly: true
                text: backupSettings.path
                placeholderText: qsTr("Главная директория бэкапов")

                FolderDialog
                {
                    id:folderDialog
                    currentFolder: backupFolderPath.text;
                    onAccepted: backupFolderPath.text=currentFolder
                }

                Button {
                    id: openPath
                    x: 547
                    y: 2
                    text: qsTr("Открыть")
                    onClicked: folderDialog.open();
                }
            }

            Button {
                id: saveBackupSettingsButton
                x: 62
                y: 189
                text: qsTr("Сохрнаить")
                onClicked: aSaveBackupSettings.trigger()
            }

            Button {
                id: restoreBackupSettings
                x: 239
                y: 189
                text: qsTr("Сброс")
                onClicked: aResetSettings

            }

            SpinBox {
                id: howOften
                x: 285
                y: 102
                value: backupSettings.shedule
                Label {
                    id: label
                    x: -427
                    width: 219
                    text: qsTr("Раз во сколько дней:")
                    anchors.right: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 16
                }
                from: 1
            }

            SpinBox {
                id: spinBox
                x: 98
                y: 279
                from: 0
                to:23
            }

            SpinBox {
                id: spinBox1
                x: 257
                y: 279
                from:0
                to:59
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
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 0
                clip: true

                ToolButton {
                    id: doBackupButton
                    x: 0
                    y: 0
                    text: qsTr("Сделать бэкап")
                    onClicked: aDoBackup.trigger()
                }
                ToolButton {
                    id: deleteBackupFileButton
                    text: qsTr("Удалить бэкап")
                    anchors.left: doBackupButton.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    onClicked: aDeleteBackupFile.trigger()
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
