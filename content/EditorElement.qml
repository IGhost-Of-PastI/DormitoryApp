import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import content

Item {
    id: item1
    Rectangle {
        id: rectangle
        y: 436
        height: 44
        color: "#ffffff"
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
        }
    }

        property var columnInfoList
        property var columnValues

        ListModel {
           id: listModel
        }
        ListView {
            id: listView
            anchors.fill: parent
            model: listModel
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
            }

            delegate: Row {
                required property var modelData
                required property string columnName
                width: listView.width
                height: implicitHeight

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: columnName
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    Loader {
                        id: editorLoader
                        width: parent.width
                        sourceComponent: getEditorComponent(modelData)
                    }
                }
            }
        }

        function getEditorComponent(columnInfo) {
               if (columnInfo.isPK) {
                   return null; // Не создаем элемент редактирования для ключевых колонок
               } else if (columnInfo.isFK) {
                   return comboBoxComponent;
               } else if (columnInfo.columnType === "boolean") {
                   return checkBoxComponent;
               } else if (columnInfo.columnType === "varchar" || columnInfo.columnType === "text") {
                   return textFieldComponent;
               } else if (columnInfo.columnType === "int") {
                   return spinBoxComponent;
               } else if (columnInfo.columnType === "date") {
                                  return calendarComponent;
                              }

               return null;
           }

        Component {
                id: checkBoxComponent
                CheckBox {
                    checked: columnValues[modelData.columnName]
                    onCheckedChanged: updateColumnValue(modelData.columnName, checked)

                    function updateData(value) {
                        console.log("CheckBox updateData called with value: " + value);
                        checked = (value === "true");
                    }
                }
            }

            Component {
                id: textFieldComponent
                TextField {
                    text: columnValues[modelData.columnName]
                    maximumLength: modelData.maxLength
                    onTextChanged: updateColumnValue(modelData.columnName, text)

                    function updateData(value) {
                        console.log("TextField updateData called with value: " + value);
                        text = value;
                    }
                }
            }

            Component {
                id: comboBoxComponent
                ComboBox {
                    model: ["Option1", "Option2", "Option3"] // Пример модели, замените на вашу
                    currentIndex: getComboBoxIndex(modelData.columnName, columnValues[modelData.columnName])
                    onCurrentIndexChanged: updateColumnValue(modelData.columnName, currentIndex)

                    function updateData(value) {
                        console.log("ComboBox updateData called with value: " + value);
                        currentIndex = getComboBoxIndex(modelData.columnName, value);
                    }
                }
            }

            Component {
                id: spinBoxComponent
                SpinBox {
                    value: columnValues[modelData.columnName]
                    from: 0
                    to: 100
                    stepSize: 1
                    onValueChanged: updateColumnValue(modelData.columnName, value)

                    function updateData(value) {
                        console.log("SpinBox updateData called with value: " + value);
                        value = parseInt(value);
                    }
                }
            }

            Component {
                id: calendarComponent
                /*Calendar {
                   // selectedDate: new Date(columnValues[modelData.columnName])
                   // onSelectedDateChanged: updateColumnValue(modelData.columnName, selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat))


                }*/
                GridLayout {
                    columns: 2

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
                        month: Calendar.December
                        year: 2015
                        locale: Qt.locale("en_US")

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    function updateData(value) {
                        console.log("Calendar updateData called with value: " + value);
                        selectedDate = new Date(value);
                    }
                }


            }


            function getComboBoxIndex(columnName, value) {
                    var index = comboBoxComponent.model.indexOf(value);
                    return index !== -1 ? index : -1; // Если значение не найдено, возвращаем -1 (никакой)
                }

                function updateEditors(values) {
                    columnValues = values;
                    listView.forceLayout(); // Обновляем ListView
                }

                function populateModel() {
                    listModel.clear();
                    for (var i = 0; i < columnInfoList.length; i++) {
                        var columnInfo = columnInfoList[i];
                        if (!columnInfo.isPK) {
                            listModel.append(columnInfo);
                        }
                    }
                }

                function updateAllEditors(value) {
                    for (var i = 0; i < listView.count; i++) {
                        var item = listView.itemAtIndex(i);
                        if (item && item.editorLoader.item) {
                            item.editorLoader.item.updateData(value);
                        }
                    }
                }

                onColumnInfoListChanged: {
                      populateModel(); // Обновляем модель ListView при изменении columnInfoList
                  }

                  onColumnValuesChanged: {
                      updateEditors(columnValues); // Заполняем редакторы при изменении columnValues
                  }


}
