import QtQuick
import QtQuick.Controls
//import Qt.labs.calendar
import content

Rectangle {
    id: rectangle
    //width: 1920
    //height: 1080
    //anchors.fill:parent
    signal requestPop()

    Component.onCompleted:
    {
        logsView.tablename="logs"

        var filtercolumns = MainSQLConnection.getAllColumns("logs");
        for (var i = 0;i<filtercolumns.length;i++)
        {
            searchModel.append({"display":filtercolumns[i]});
            sortModel.append({"display":filtercolumns[i]});
        }
    }

    Action
    {
        id:aGoBack
        onTriggered:
        {
            requestPop();
        }
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height:100
        TextField
        {
            id:fieldSearch
            anchors.left: goBack.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            placeholderText: "Ввод фильтра";
        }
        ComboBox
        {
            id:searchColumnCB
            model:ListModel
            {
                id:searchModel
            }

            anchors.left: fieldSearch.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        ToolButton {
            id: optionFilterButton
            text: qsTr("Фильтр")
            anchors.left: searchColumnCB.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked:
            {
                aAcceptAllFilters.trigger();
            }
        }
        ToolSeparator {
            id: toolSeparator1
            width: 25
            anchors.left: optionFilterButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        ComboBox {
            id: sortColumn
            model:ListModel
            {
                id:sortModel
            }

            anchors.left: toolSeparator1.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        Item {
            id: item1
            width: 300
            anchors.left: sortColumn.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            RadioButton {
                id: descSort
                width: 140
                text: qsTr("По убыванию")
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }

            RadioButton {
                id: ascSort
                text: qsTr("По возрастанию")
                anchors.left: descSort.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                checked: true
            }
        }

        GroupBox {
            id: groupBox
            y: 7
            width: 291
            height: 86
            anchors.left: item1.right
            anchors.leftMargin: 0
            title: qsTr("Выборка по дате:")

            Calendar_TimeFilter
            {
                id:calendarTime
            }
        }

        ToolButton {
            id: toolButton
            x: 1141
            text: qsTr("Обновить")
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked: {
                aRefresh.trigger();
            }
        }



        ToolSeparator {
            id: toolSeparator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }

        ToolSeparator {
            id: toolSeparator2
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 0
            anchors.bottomMargin: 0
        }

        ToolButton {
            id: goBack
            width: 121
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
        orientation: Qt.Vertical
        id:tableSplit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: -3
        Rectangle
        {
            id: rectangle1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            SplitView.preferredHeight: 250

            Label
            {
                id:label1
                text: "Список логов"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignHCenter
                height:40
            }

            Table
            {
                id:logsView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: label1.bottom
                anchors.bottom: parent.bottom
                onSelectionChanged:(selectedIndex) =>{
                                       listModel.clear();
                                    var row =  logsView.getSelectedRowData();
                                       var actionType = row.find(function (item)
                                                                       {
                                                                          return item.columnName==="id_action_type"
                                                                       }    );
                                    var jsonActions= row.find(function (item)
                                    {
                                        return item.columnName==="action_description";
                                    });
                                     //  row.action_description);
                                       var parsedJson=JSON.parse(jsonActions.columnValue);
                                    var table_name= parsedJson.table;
                                    var details;
                                       switch (actionType.columnValue)
                                       {
                                           case "Изменения в таблице":
                                                details=parsedJson.changes;
                                           break;
                                           case "Добавление в таблице":
                                           details=parsedJson.inserted;
                                           break;
                                           case "Удаление из таблицы":
                                           details=parsedJson.deleted;
                                           break;
                                           default:
                                       }
                                       if (details.length > 0) {
                                                   var keys= Object.keys(details[0])
                                           var values=[];
                                                      for (let i = 0; i < keys.length; i++) {
                                                                values.push({value:keys[i]});
                                                          //listModel.append({"value": keys[i] });
                                                      }
                                                        listModel.append({values:values});

                                               for (var j = 0; j < details.length; j++) {
                                               var innervalues=[];
                                                        var values2=Object.values(details[j]);
                                               for (var k=0;k<values2.length;k++)
                                               {
                                                   innervalues.push({value:String(values2[k])});
                                               }
                                                       //innervalues.push({"value":details[j]});
                                               listModel.append({values:innervalues});
                                               }

                                           }

                                               }
                                   }
            }
        Rectangle
        {
            id: rectangle2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            SplitView.preferredHeight: 500

            Label
            {
                id:infAboutLog
                text: "Информация из конкретного лога"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignHCenter
                height:40
            }

            ListView
            {
                id:listChanges
                model:ListModel
                {
                    id:listModel
                }

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: infAboutLog.top
                anchors.bottom: parent.bottom
                delegate: Row
                    {
                                spacing: 5
                                Repeater {
                                    model: values
                                    ItemDelegate
                                    {
                                        text:value
                                    }
                                }


            }
        }
        }

    }


}
