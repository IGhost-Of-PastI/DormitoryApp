import QtQuick 2.15
import QtQuick.Controls 2.15
import "."

Rectangle {
    id: rectangle
    width: 1920
    height: 1080

    property var userinfo;

    onUserinfoChanged:
    {
       administartionSelector.userinfo=userinfo;

       var AccessesJson = JSON.parse(userinfo.acceses);
       tablesCreator = AccessesJson.valueOf("TableAccesses");
       //tableAccesses.
    }
    ListModel
                {
                    id:listModel
                }

    ToolBar {
        id: toolBar
        width: 100
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        ToolButton {
            id: toolButton
            text: qsTr("Профиль")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: toolButton2.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
        }

        ToolButton {
            id: toolButton1
            y: 813
            text: qsTr("Выйти")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
        }

        ToolButton {
            id: toolButton2
            text: qsTr("Открыть")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            onClicked: menu.open()
        }


    }
    Drawer
    {
        id:menu
        edge:Qt.LeftEdge
        x:toolBar.width
        width: 0.25 * rectangle.width
        height: parent.height
       // visible: false
       // opened:true
        ListView
        {
            model: listModel
            delegate:  Item
            {
                //id: listDelegate
                width: parent.width
                height: 40

                required property string tablename
                //required property date fileModified
                Row
                {
                    Text {
                        text: tablename
                    }
                }
            }

            id: tables
            anchors.fill: parent
    //        anchors.left: parent.left
     //       anchors.right: parent.right
      //      anchors.top: parent.top
      //      anchors.bottom: parent.bottom
      //      anchors.leftMargin: 0
       ///     anchors.rightMargin: 0
        ///    anchors.topMargin: 0
         //   anchors.bottomMargin: 0

        }
    }

    SwipeView
    {
        anchors.left: toolBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        orientation: Qt.Vertical

        AdministarationSelector
        {
            id:administartionSelector
        }
        Repeater
        {
            id:tablesCreator
            property var tableAccesses
            model: listModel

            onTableAccessesChanged:
            {
                var jsonArray= JSON.parse(tableAccesses);
                for (let i=0; i < jsonArray.length; i++)
                {
                    var tableinfo=JSON.parse(tableAccesses[i]);
                    if (tableinfo.valueOf("ViewTable"))
                    {
                        var tablename = tableinfo.valueOf("TableName");
                        var tableActionsAccesses =JSON.parse(tableinfo.valueOf("TableActionsAccesses"));
                        var add = tableActionsAccesses.valueOf("Add");
                        var edit = tableActionsAccesses.valueOf("Edit");
                        var tdelete = tableActionsAccesses.valueOf("Delete");
                        listModel.append({"tablename":tablename,"IsAdd":add,"IsEdit":edit,"IsDelete":tdelete});
                    }
                }
            }

            delegate:TableManipulator
            {
                tablename:listModel.tablename;
                isAdd:listModel.IsAdd;
                isDelete:listModel.IsDelete;
                isEdit:listModel.IsEdit;
            }
        }
    }


}
