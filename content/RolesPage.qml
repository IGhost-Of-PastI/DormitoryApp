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

  //  onColumnInfoListChanged: {
  //      populateModel(
  //                  )
   // }

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

    ListModel {
        id: listModel
    }


    ListView {
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



        TextField {
            id:name
            placeholderText: "Enter text"
            width: parent.width
        }

        TextField {
            id:description
            placeholderText: "Enter text"
            width: parent.width
        }

        Column {
            id:userAccessesPart
            anchors.fill: parent

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
        Repeater
        {

        }
    }

            Component {
                id: tableAccesses
                Column {
                    //required property var modelData
                    property string tablename

                    Text { text: tablename }
                    CheckBox { id: viewtable; text: "Показывать таблицу?" }
                    Column {
                        CheckBox { id: isadd; text: "Разрешить добавление записей?" }
                        CheckBox { id: isedit; text: "Разрешить редактирование записей?" }
                        CheckBox { id: isdelete; text: "Разрешить удаление записей?" }
                    }

                    function setData(data) {
                        viewtable.checked = data.ViewTable || false
                        isadd.checked = data.TableActionsAccesses.Add || false
                        isedit.checked = data.TableActionsAccesses.Edit || false
                        isdelete.checked = data.TableActionsAccesses.Delete || false
                    }

                    function getData() {
                        var mainAccesses={
                            //viewtable: viewtable.checked,
                            Add: isadd.checked,
                            Edit: isedit.checked,
                            Delete: isdelete.checked
                        }
                        var tableAccesesContainer =
                        {
                            TableName:tablename,
                            ViewTable:viewtable.checked,
                            TableActionsAccesses:mainAccesses
                        }
                        return tableAccesesContainer;
                    }
                }
    }

            function collectData() {
                var collectedData = []

                collectData.push({"columnInfo":"name","value":name.text});
                collectData.push({"columnInfo":"description","value":description.text});
                var userAcc= userAccessesPart.getData();
                var TablesAccs=[];
                for (var i = 0; i < loadedItems.length; i++) {
                    var item = loadedItems[i]
                    TablesAccs.push(item.getData());
                }
                var FinalJSon={
                    UserAccesses:userAcc,
                    TableAccesses:TablesAccs
                }
                collectData().push({"columnInfo":"acceses","value":JSON.stringify(FinalJSon)});
                return collectedData
            }

    function updateEditors(values) {
        for (var i = 0; i < loadedItems.length; i++) {
            var item = loadedItems[i]
            if (item.columnName === "name")
            {
                name.text=item.columnValue;
            }
            if (item.columnName === "description")
            {
                description.text=item.columnName;
            }
            if (item.columnName==="acceses")
            {
                var ParesedJson = JSON.parse(item.columnValue);
                    userAccessesPart.setData(ParesedJson.UserAccesses);
                var TablesAccesses=ParesedJson.TableAccesses;
                for (var j=0;i<tableAccesses.length;j++)
                {
                    var tableAcc= tableAccesses[j];
                    var foundItem = loadedItems(function (item){return itme.tablename === tableAcc.TableName; })
                    foundItem.setData(tableAcc);
                }
            }
            if(item.columName === "id")
            {
                pkColumnName="id";
                iDValue=item.columnValue;

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
                var component = tableAccesses.createObject(listView)
                component.tablename=table_name;
                //listView.;
                //listView.addItem(component)
                loadedItems.push(component);
            }
        }
    }


}
