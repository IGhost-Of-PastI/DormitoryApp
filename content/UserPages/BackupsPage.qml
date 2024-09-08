import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings

Item {
    id: item1
    width: 1920
    height: 1080

    Settings
    {

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
        orientation: Qt.Horizontal
        //anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom:parent.bottom
        anchors.top: toolBar.bottom

        Rectangle
        {
            id: optionsPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            clip: true
           SplitView.preferredHeight: 200

           TextField {
               id: textField
               x: 62
               y: 19
               width: 530
               height: 56
               placeholderText: qsTr("Главная директория бэкапов")
           }

           Button {
               id: button
               x: 670
               y: 19
               text: qsTr("Открыть")
           }
           Button {
               id: button1
               x: 459
               y: 471
               text: qsTr("Сохрнаить")
           }

           Button {
               id: button2
               x: 649
               y: 479
               text: qsTr("Сброс")
           }

           SpinBox {
               id: spinBox
               x: 513
               y: 200
           }
       }
        Rectangle
        {
            id: rectangle
            SplitView.preferredHeight: 200
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: optionsPanel.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
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
                    x: 967
                    y: 340
                    text: qsTr("Tool Button")
                }

                ToolButton {
                    id: toolButton4
                    x: 1059
                    y: 340
                    text: qsTr("Tool Button")
                }
            }


            TableView
            {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: toolBar1.bottom
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                anchors.topMargin: 0
                SplitView.preferredHeight: 200
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
