import QtQuick
import QtQuick.Controls
import content

Page {

    id:item1

    //property
    property var loadedItems: []
    property string tablename
    property var columnInfoList
    property var iDValue
    property var pkColumnName;
    property var columnValues
    signal dataUpdated_Added(bool success)

    function populateModel() {
       // listModel.clear()
        for (var i = 0; i < columnInfoList.length; i++) {
            var columnInfo = columnInfoList[i]
            if (!columnInfo.isPK) {
             //   listModel.append(columnInfo)
            } else {
                pkColumnName = columnInfo.columnName
            }
        }
    }

  onColumnInfoListChanged: {
        populateModel(
                    )
    }

    onColumnValuesChanged: {
        updateEditors(
                    columnValues)
    }

    states: [
        State {
            name: "closed"
            PropertyChanges {
                target: item1
                visible: false
            }
        },
        State {
            name: "addMode"
            PropertyChanges {
                target: item1
                visible: true
            }
            PropertyChanges {
                target: headerTable
                mode: "Добавление"
            }
        },
        State {
            name: "editMode"
            PropertyChanges {
                target: item1
                visible: true
            }
            PropertyChanges {
                target: headerTable
                mode: "Редактирование"
            }
        }
    ]
    header: ToolBar {
        Row {
            id: headerTable
            property string mode: ""
            spacing: 10
            Label {
                text: "Режим: " + headerTable.mode
                font.bold: true
                font.pointSize: 12
            }
        }
    }

    footer: ToolBar {
        id: rectangle
        height: 44
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Button {
            id: saveButton
            x: 85
            y: 0
            text: qsTr("Сохранить")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked: {
                if (item1.state === "addMode") {
                    var data = collectData()
                    var addsuccess= MainSQLConnection.insertRecord(tablename,columnInfoList, data)
                    dataUpdated_Added(addsuccess)
                } else if (item1.state === "editMode") {
                    var editData = collectData()
                    var editsuccess= MainSQLConnection.updateRecord(tablename,columnInfoList, editData,pkColumnName,iDValue)
                    dataUpdated_Added(editsuccess)
                }
            }

        }

        Button {
            id: cancelButton
            y: -436
            width: 119
            text: qsTr("Отмена")
            anchors.left: saveButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            onClicked: {
                item1.state = "closed"
            }
        }
    }

    /*ListModel {
        id: listModel
    }*/


 /*   ListView {
        id: listView
        cacheBuffer: 1500
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        model: listModel
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
*/

Column{
    width: parent.width
    id:nameColumn
    TextField {
        id:name
        placeholderText: "Enter text"
    }
}
      Column{
          id:descriptionColumn
          width: parent.width
          anchors.top: nameColumn.bottom
          TextField {
              id:description
              placeholderText: "Enter text"

          }
      }



        Column {

            id:userAccessesPart
            anchors.top: descriptionColumn.bottom
             width: parent.width

            CheckBox { id: viewLogs; text: "Просмотр логов" }
            CheckBox { id: configureBackups; text: "Управление бэкапами" }
            CheckBox { id: reports; text: "Создание отчетов" }
            CheckBox { id: freeQueres; text: "Произвольные запросы" }
           // CheckBox { id: configureUser; text: "Настройки пользователя" }

            function setData(data) {
                viewLogs.checked = data.ViewLogs || false
                configureBackups.checked = data.ConfigureBackups || false
                reports.checked = data.Reports || false
                freeQueres.checked = data.FreeQueries || false
               // configureUser.checked = data.configureUser || false
            }

            function getData() {
                return {
                    ViewLogs: viewLogs.checked,
                    ConfigureBackups: configureBackups.checked,
                    Reports: reports.checked,
                    FreeQueries: freeQueres.checked,
                   // ConfigureUser: configureUser.checked
                }
            }
        }
        Column
        {
            anchors.top: userAccessesPart.bottom
             width: parent.width
             anchors.bottom: parent.bottom
             Flickable {
                 id: flickable
                 width: parent.width
                 height: parent.height
                 contentWidth: parent.width
                 clip: true

                 Column {
                     id: contentColumn
                     width: flickable.width

                     Repeater {
                         id: tablerepator
                         model: ListModel {
                             id: repeatormodel
                         }
                         delegate: Column {
                             width: parent.width
                             spacing: 10

                             required property string tablename

                             Text { text: tablename }
                             CheckBox { id: viewtable; text: "Показывать таблицу?" }
                             Column {
                                 CheckBox { id: isadd; text: "Разрешить добавление записей?" }
                                 CheckBox { id: isedit; text: "Разрешить редактирование записей?" }
                                 CheckBox { id: isdelete; text: "Разрешить удаление записей?" }
                             }

                             function setData(data) {
                                 viewtable.checked = data.ViewTable || false;
                                 isadd.checked = data.TableActionsAccesses.Add || false;
                                 isedit.checked = data.TableActionsAccesses.Edit || false;
                                 isdelete.checked = data.TableActionsAccesses.Delete || false;
                             }

                             function getData() {
                                 return {
                                     TableName: tablename,
                                     ViewTable: viewtable.checked,
                                     TableActionsAccesses: {
                                         Add: isadd.checked,
                                         Edit: isedit.checked,
                                         Delete: isdelete.checked
                                     }
                                 };
                             }
                         }
                     }
                 }

                 // Привязка высоты контента к высоте колонки
                 contentHeight: contentColumn.height
             }

        }


  //}

            function collectData() {
                var collectedData = []

                collectedData.push({"columnInfo":"name","value":name.text});
                collectedData.push({"columnInfo":"description","value":description.text});
                var userAcc= userAccessesPart.getData();
                var TablesAccs=[];
                for (var i = 0; i < tablerepator.count; i++) {
                    var item = tablerepator.itemAt(i); //loadedItems[i]
                    TablesAccs.push(item.getData());
                }
                var FinalJSon={
                    UserAccesses:userAcc,
                    TableAccesses:TablesAccs
                }
                collectedData.push({"columnInfo":"acceses","value":JSON.stringify(FinalJSon)});
                return collectedData
            }

    function updateEditors(values) {
        for (var i = 0; i < columnInfoList.length; i++) {
            var columninfo = columnInfoList[i]
            var columnNameToFind = columninfo.columnName;
            var foundItem = values.find(function (item) {
                return item.columnName === columnNameToFind
            });

            if (foundItem.columnName === "name")
            {
                name.text=foundItem.columnValue;
            }
            if (foundItem.columnName === "description")
            {
                description.text=foundItem.columnName;
            }
            if (foundItem.columnName==="acceses")
            {
                var ParesedJson = JSON.parse(foundItem.columnValue);
                    userAccessesPart.setData(ParesedJson.UserAccesses);
                var TablesAccesses=ParesedJson.TableAccesses;
                for (var j=0;j<tablerepator.count;j++)
                {
                    var item=tablerepator.itemAt(j);
                    var findtablename= item.tablename;
                    var foundItem2= TablesAccesses.find(function(item){return item.TableName === findtablename} );
                    item.setData(foundItem2);
                }
            }
            if(foundItem.columnName === "id")
            {
                //pkColumnName="id";
                iDValue=foundItem.columnValue;

            }
        }
    }

    Component.onCompleted: {
        var tables= MainSQLConnection.getAllTables();
        for (var i=0;i<tables.length;i++)
        {
            var table_name= tables[i];
            if(tablename !== "logs" && tablename !=="logs_action_types")
            {
                repeatormodel.append({"tablename":table_name});
                //var component = tableAccesses.createObject(listView)
                //component.tablename=table_name;
                //listView.;
                //listView.addItem(component)
                //loadedItems.push(component);
            }
        }
    }


}
