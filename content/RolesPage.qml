import QtQuick
import QtQuick.Controls

Page {

    id:item1

    property var loadedItems: []
    property string tablename
    property var columnInfoList
    property var iDValue
    property var pkColumnInfo
    property var columnValues
    signal dataUpdated_Added(bool success)

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
        y: 436
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
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            onClicked: {
                if (item1.state === "addMode") {
                    var data = collectData()
                    var addsuccess= MainSQLConnection.insertRecord(tablename,columnInfoList, data)
                    dataUpdated_Added(addsuccess)
                } else if (item1.state === "editMode") {
                    var editData = collectData()
                    var editsuccess= MainSQLConnection.updateRecord(tablename,columnInfoList, editData,pkColumnInfo.columnName,iDValue)
                    dataUpdated_Added(editsuccess)
                }
            }
            function collectData() {
                var collectedData = []
                for (var i = 0; i < loadedItems.length; i++) {
                    var item = loadedItems[i]
                    collectedData.push({
                                           "columnInfo": item.modelData.columnName,
                                           "value": item.getData()
                                       })
                }
                return collectedData
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

        delegate: Row {
            id: row
            required property var modelData
            width: listView.width
            height: implicitHeight

            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: modelData.columnName
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                Loader {
                    id: editorLoader
                    //property var modelData:row.modelData
                    width: parent.width
                    sourceComponent: getEditorComponent(modelData)
                    onLoaded: {
                        if (item) {
                            item.modelData = modelData
                            loadedItems.push(item)
                        }
                    }
                }
            }
        }
    }

    function getEditorComponent(columnInfo) {
        if (columnInfo.isPK) {
            return null // Не создаем элемент редактирования для ключевых колонок
        } else if (columnInfo.isFK) {
            return comboBoxComponent
        }
    }

    Component
    {
        id: userAccesses
        Column
        {
            anchors.fill: parent
            CheckBox
            {
                id:viewLogs
                text: "Просмотр логов"
            }
            CheckBox
            {
                id:configureBackups
                text:"Управление бэкапами"
            }
            CheckBox
            {
                id: reports
                text: "Создание отчетов"
            }
            CheckBox
            {
                id: freeQueres
                text: "Произвольные запросы"
            }
            CheckBox
            {
                id: configureUser
                text: "Настройки пользователя"
            }
            function getData() {
                return value
            }

            function updateData(value) {
                console.log("SpinBox updateData called with value: " + value)
                value = parseInt(value)
            }
        }
    }
    Component
    {
        id: tableAccesses

        Column
        {
           required property string tablename
            Text
            {
                text: tablename
            }
            CheckBox
            {
                id: viewtable
                text: "Показывать таблицу?"
            }
            Column
            {
                CheckBox
                {
                    id:isadd
                    text:"Разрешить добавление записей?"
                }
                CheckBox
                {
                    id:isedit
                    text:"Разрешить редактирвоание записей?"
                }
                CheckBox
                {
                    id:isdelete
                    text:"Разрешить удаление записей?"
                }
            }
            function getData() {
                return value
            }

            function updateData(value) {
                console.log("SpinBox updateData called with value: " + value)
                value = parseInt(value)
            }
        }
    }


    function updateEditors(values) {
        for (var i = 0; i < loadedItems.length; i++) {
            var item = loadedItems[i]
            var columnNameToFind = item.modelData.columnName
            var foundItem = values.find(function (item) {
                return item.columnName === columnNameToFind
            });
            item.updateData(foundItem.columnValue)
        }
        var column = values.find(function (item) {
            return item.columnName === pkColumnInfo.columnName
        });
        iDValue = column.columnValue;
    }

    function populateModel() {
        listModel.clear()
        for (var i = 0; i < columnInfoList.length; i++) {
            var columnInfo = columnInfoList[i]
            if (!columnInfo.isPK) {
                listModel.append(columnInfo)
            } else {
                pkColumnInfo = columnInfo
            }
        }
    }




}
