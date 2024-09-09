import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings
import QtQuick.Dialogs
import Qt.labs.folderlistmodel

Item {
    id: item1
    width: 1920
    height: 1080

    Settings
    {
        id:backupSettings
        category: "BackupSection"
        fileName: "settings.ini"
        property alias path: textField.text
        property alias shedule: spinBox.value
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

            onClicked: backupOptions.open()
        }

        ToolButton {
            id: toolButton
            x: 0
            y: -222
            text: qsTr("Назад")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
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

            TextField {
                id: textField
                x: 62
                y: 19
                width: 530
                height: 56
                readOnly: true
                placeholderText: qsTr("Главная директория бэкапов")

                FolderDialog
                {
                    id:folderDialog
                    currentFolder: textField.text;
                    onAccepted: textField.text=currentFolder
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
                id: saveBackupSettings
                x: 62
                y: 189
                text: qsTr("Сохрнаить")
                onClicked: backupSettings.sync()
            }

            Button {
                id: restoreBackupSettings
                x: 239
                y: 189
                text: qsTr("Сброс")

            }

            SpinBox {
                id: spinBox
                x: 285
                y: 102

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
        }
        Rectangle
        {
            id: rectangle
            //  anchors.top:optionsPanel.bottom
            //  anchors.right: parent.right
            //  anchors.left:parent.left
            SplitView.preferredHeight: splitView.height/2
            SplitView.fillWidth: true
            //   height: splitView.height/2
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
                    id: toolButton2
                    x: 0
                    y: 0
                    text: qsTr("Сделать бэкап")
                }
                ToolButton {
                    id: toolButton3
                    text: qsTr("Удалить бэкап")
                    anchors.left: toolButton2.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                }
            }


            ListView
            {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: toolBar1.bottom
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                anchors.topMargin: 0

                FolderListModel
                {
                    id:folderModel
                    folder: backupSettings.path
                    nameFilters: ["*.aml"]
                }

                Component
                {
                    id: listDelegate
                    required property string fileName
                    required property date cretionDate
                    Rectangle
                    {
                        Text {
                            id: name
                            text: fileName
                        }
                        Text {
                            id: name2
                            text: cretionDate
                        }
                    }
                }
                model:folderModel
                delegate: listdelegate
            }
        }


    }





    //Drawer
    //{
    //    id: backupOptions
    //    height: parent.height
    //    width:500
    //    edge: Qt.TopEdge
    //    y:toolBar.height
    //    visible:true
    //    opened:true

    //    contentItem:
    //        Column
    //        {

    //        }
    //}


}
