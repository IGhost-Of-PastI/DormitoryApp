import QtQuick
import QtQuick.Controls
import "."

Page {
    id: rectangle

    property var userinfo

    onUserinfoChanged: {
        var AccessesJson = JSON.parse(userinfo.acceses)
        var tableAccesses = AccessesJson.TableAccesses
        var jsonArray = tableAccesses

        listModel.append({"userinfo":userinfo,"tablename":"","tableaccJson":null,"index":0});
        for (var i = 0; i < jsonArray.length; i++) {
            var tableinfo = tableAccesses[i]
            if (tableinfo.ViewTable) {
                var tablename = tableinfo.TableName
                if (String(tablename) !== "Logs" && String(tablename) !=="Logs_Action_Types")
                {
                    var tableActionsAccesses = tableinfo.TableActionsAccesses
                    listModel.append({"userinfo":userinfo,"tablename":tablename,"tableaccJson":tableActionsAccesses,"index":i+1});
                }
            }
        }
    }
    ListModel {
        id: listModel
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
    Drawer {
        id: menu
        edge: Qt.LeftEdge
        x: 100
        width: 0.25 * rectangle.width
        height: parent.height
        ListView {
            boundsBehavior: Flickable.StopAtBounds
            model: listModel
            delegate: Item {
                width: parent.width
                height: 40

                required property string tablename
                required property int index
                Row {
                    Text {
                        text: tablename
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        tables.currentIndex = index
                        swipeView.currentIndex = tables.currentIndex
                    }
                }
            }

            id: tables
            anchors.fill: parent
            highlight: Rectangle {
                color: "lightsteelblue"
                radius: 1
            }
            focus: true
        }
    }

    SwipeView {
        id: swipeView
        anchors.left: toolBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        orientation: Qt.Vertical
        interactive: false
        Repeater {
            id: tablesCreator
            model: listModel

            delegate: Page {
                required property string tablename
                header: ToolBar {
                    Row {
                        spacing: 10
                        Label {
                            text: "Название таблицы: " + tablename
                            font.bold: true
                            font.pointSize: 12
                        }
                    }
                }

                Loader{
                    id:contentLoader
                    anchors.fill:parent
                    sourceComponent: getContentComponent(tablename)
                    onLoaded: {
                                   if (item) {
                                       item.tablename = tablename;
                                   }
                    }
                }
            }
        }
    }
    function getContentComponent(tablename)
    {
        if(String(tablename) === "")
        {
            return adminitartorPageComponent;
        } else if (String(tablename)==="Jobs")
        {
            return rolesTableComponent;
        } else
        {
            return generalTableComponent;
        }
    }
    Component
    {
        id:rolesTableComponent

        RolesPage
        {
           property string tablename
        }
    }
    Component
    {
        id:generalTableComponent

        TableManipulator {
        }
    }
    Component
    {
        id:adminitartorPageComponent

        AdministarationSelector {
            property string tablename
        }
    }

}
