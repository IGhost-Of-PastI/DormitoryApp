import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import content

Page {
    id: item1

    property var loadedItems: []
    property string tablename
    property var columnInfoList
    property var iDValue
    property var pkColumnInfo
    property var columnValues
    signal dataUpdated_Added(string success)

    onColumnInfoListChanged: {
        populateModel(
                    ) // Обновляем модель ListView при изменении columnInfoList
    }

    onColumnValuesChanged: {
        updateEditors(
                    columnValues) // Заполняем редакторы при изменении columnValues
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
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 0

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
                    var addsuccess = MainSQLConnection.insertRecord(
                                tablename, columnInfoList, data);
                    dataUpdated_Added(addsuccess);
                } else if (item1.state === "editMode") {
                    var editData = collectData()
                    var editsuccess = MainSQLConnection.updateRecord(
                                tablename, columnInfoList, editData,
                                pkColumnInfo.columnName, iDValue);

                    dataUpdated_Added(editsuccess);
                }
            }
            function collectData() {
                var collectedData = []

                for (var i = 0; i < loadedItems.length; i++) {
                    var item = loadedItems[i]
                    if(item.modelData.columnName==="password" && item1.state==="editMode")
                    {
                        var password = item.getData();
                        if(password !=="")
                        {
                            collectedData.push({
                                                   "columnInfo": item.modelData.columnName,
                                                   "value": item.getData()
                                               })
                        }
                    }
else
                    {
                        collectedData.push({
                                               "columnInfo": item.modelData.columnName,
                                               "value": item.getData()
                                           })
                    }


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
                clearAll();
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
        } else if (columnInfo.columnType === "varchar" && columnInfo.columnName==="password") {
            return passwordComponent
        }else if (columnInfo.columnType === "bool") {
            return checkBoxComponent
        } else if (columnInfo.columnType === "text") {
            return textFieldComponent
        } else if (columnInfo.columnType === "varchar") {
            return varcharFieldComponent
        } else if (columnInfo.columnType === "int4" || columnInfo.columnType === "int8") {
            return spinBoxComponent
        } else if (columnInfo.columnType === "date") {
            return calendarComponent
        }

        return null
    }

    Component
    {
        id: passwordComponent
        TextField {
            property string oldPassword
            property var modelData
            echoMode: TextInput.Password
            function getData() {
                if (oldPassword !== "" && text==="")
                {
                    return "";
                }
                else
                {
                    return text;
                }
            }

            function updateData(value) {
                console.log("TextField updateData called with value: " + value)
                oldPassword = value
            }
            function clear()
            {
                oldPassword="";
                text="";
            }
        }
    }

    Component {
        id: checkBoxComponent
        CheckBox {
            property var modelData
            function getData() {
                return checked
            }
            function updateData(value) {
                console.log("CheckBox updateData called with value: " + value)
                checked = (value === "true")
            }
            function clear()
            {
                checked=false;
            }
        }
    }

    Component {
        id: textFieldComponent
        TextField {
            property var modelData
            function getData() {
                return text
            }

            function updateData(value) {
                console.log("TextField updateData called with value: " + value)
                text = value
            }
            function clear()
            {
                text="";
            }
        }
    }
    Component {
        id: varcharFieldComponent
        TextField {
            property var modelData
            maximumLength: modelData.maxLength
            function getData() {
                return text
            }
            function updateData(value) {
                console.log("TextField updateData called with value: " + value)
                text = value
            }
            function clear()
            {
                text="";
            }
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            id: thiscombobox
            property var modelData
            onModelDataChanged: {
                var modelList = MainSQLConnection.getFKValues(
                            modelData.fkColumnInfo.key,
                            modelData.fkColumnInfo.value)
                for (var i = 0; i < modelList.length; i++) {
                    var MCSC = modelList[i]
                    comboboxModel.append({
                                             "pKValue": MCSC.key,
                                             "sValue": MCSC.value,
                                             "index": i
                                         })
                }
            }

            model: ListModel {
                id: comboboxModel
            }
            delegate: ItemDelegate {
                required property string sValue
                required property string pKValue
                width: parent.width
                Text {

                    text: sValue
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    console.log("Selected value: " + comboboxModel.get(
                                    currentIndex).sValue)
                    displayText = comboboxModel.get(currentIndex).sValue
                }
            }
            function getData() {
                if (currentIndex !== -1) {
                    return comboboxModel.get(currentIndex).pKValue
                }
            }

            function updateData(value) {
                console.log("ComboBox updateData called with value: " + value)
                for (var i = 0; i < comboboxModel.count; i++) {
                    if (comboboxModel.get(i).sValue === value) {
                        currentIndex = i
                        break
                    }
                }
            }
            function clear()
            {
                currentIndex=-1;
                displayText="";
            }
        }
    }

    Component {
        id: spinBoxComponent
        SpinBox {
            property var modelData
            stepSize: 1
            //onValueChanged: updateColumnValue(modelData.columnName, value)
            function getData() {
                return value
            }

            function updateData(value) {
                console.log("SpinBox updateData called with value: " + value)
                value = Number(value)
            }
            function clear()
            {
                value=0;
            }
        }
    }

    Component {
        id: calendarComponent
        GridLayout {
            property var modelData

            columns: 2
            rows: 2
            Column {
                id: selectColumn
                property var currentDate: new Date()
                property int currentMonth: currentDate.getMonth()
                property int currentYear: currentDate.getFullYear()
                spacing: 10

                Row {
                    spacing: 10
                    Button {
                        text: "<<"
                        width: 30
                        height: 30
                        onClicked: {
                            selectColumn.currentYear--
                        }
                    }
                    Text {
                        text: selectColumn.currentYear.toString()
                    }
                    Button {
                        text: ">>"
                        width: 30
                        height: 30
                        onClicked: {
                            selectColumn.currentYear++
                        }
                    }
                }
                Row {
                    spacing: 10
                    Button {
                        text: "<"
                        width: 30
                        height: 30
                        onClicked: {
                            if (selectColumn.currentMonth === Calendar.January) {
                                selectColumn.currentMonth = Calendar.December
                                selectColumn.currentYear--
                            } else {
                                selectColumn.currentMonth--
                            }
                        }
                    }
                    Text {
                        text: Qt.formatDate(new Date(selectColumn.currentYear,
                                                     selectColumn.currentMonth,
                                                     1), "MMMM")
                    }
                    Button {
                        text: ">"
                        width: 30
                        height: 30
                        onClicked: {
                            if (selectColumn.currentMonth === Calendar.December) {
                                selectColumn.currentMonth = Calendar.January
                                selectColumn.currentYear++
                            } else {
                                selectColumn.currentMonth++
                            }
                        }
                    }
                }
            }

            DayOfWeekRow {
                locale: grid.locale

                Layout.column: 1
                Layout.fillWidth: true
            }

            WeekNumberColumn {
                month: grid.month
                year: grid.year
                locale: grid.locale

                Layout.fillHeight: true
            }

            MonthGrid {
                id: grid
                month: selectColumn.currentMonth
                year: selectColumn.currentYear
                locale: Qt.locale("ru_RU")

                property date selectedDate: new Date()
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: Item {
                    id: delegateItem

                    property bool isSelectedDay: (model.year === grid.selectedDate.getFullYear()
                                                  && model.month === grid.selectedDate.getMonth()
                                                  && model.day === grid.selectedDate.getDate(
                                                      ))

                    Rectangle {
                        anchors.fill: parent
                        color: delegateItem.isSelectedDay ? "lightblue" : "transparent"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: model.date.getDate()
                    }
                }
                onPressed: function (date) {
                    grid.selectedDate = date
                }
            }
            function getData() {
                return grid.selectedDate.toLocaleDateString(Qt.locale(),
                                                            Locale.ShortFormat)
            }
            function updateData(value) {
                grid.selectedDate = value
            }
            function clear()
            {
                grid.selectedDate=new Date();
            }
        }
    }

    function clearAll()
    {
        for (var i = 0; i < loadedItems.length; i++) {
           var item = loadedItems[i];
            item.clear();
        }
    }

    function updateEditors(values) {
        for (var i = 0; i < loadedItems.length; i++) {
            var item = loadedItems[i]
            var columnNameToFind = item.modelData.columnName
            var foundItem = values.find(function (item) {
                return item.columnName === columnNameToFind
            })
            item.updateData(foundItem.columnValue)
        }
        var column = values.find(function (item) {
            return item.columnName === pkColumnInfo.columnName
        })
        iDValue = column.columnValue
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
