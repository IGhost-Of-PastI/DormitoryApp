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
       // var JsonString = JSON.stringify(userinfo.acceses);
       var AccessesJson = JSON.parse(userinfo.acceses);
       tablesCreator.tableAccesses = AccessesJson.TableAccesses;
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
                required property int index
                //required property date fileModified
                Row
                {
                    Text {
                        text: tablename
                    }

                }
                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tables.currentIndex=index;
                                        //tablesCreator.current
                                        swipeView.currentIndex = tables.currentIndex;
                                        //menu.close();
                                    }
                                }
            }

            id: tables
            anchors.fill: parent
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            focus: true
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
        id:swipeView
        anchors.left: toolBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        orientation: Qt.Vertical

        Repeater
        {
            id:tablesCreator
            property var tableAccesses
            model: listModel

            onTableAccessesChanged:
            {
                var jsonArray= tableAccesses;
                for (let i=0; i < jsonArray.length; i++)
                {
                    var tableinfo=tableAccesses[i];
                    if (tableinfo.ViewTable)
                    {
                        var tablename = tableinfo.TableName;
                        var tableActionsAccesses =tableinfo.TableActionsAccesses;
                        var add = tableActionsAccesses.Add;
                        var edit = tableActionsAccesses.Edit;
                        var tdelete = tableActionsAccesses.Delete;
                        listModel.append({"tablename":String(tablename),"isAdd":Boolean(add),"isEdit":Boolean(edit),"isDelete":Boolean(tdelete),"index":i});
                    }
                }
            }

            delegate:Page
            {
                required property string tablename
                required property string isAdd
                required property string isDelete
                required property string isEdit

                TableManipulator
                {
                    avalAdd: isAdd;
                    avalEdit: isEdit
                    avalDelete: isDelete
                    tablemodel: MainSQLConnection.getRelatioanlTableModel(tablename);
                //tablename:tablename;
                //isAdd:isAdd;
                //isDelete:isDelete;
                //isEdit:isEdit;
                }
            }
        }
        AdministarationSelector
        {
            id:administartionSelector
        }
    }


}
