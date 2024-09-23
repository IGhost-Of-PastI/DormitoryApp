import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Column {
    property bool withTime
    onWidthChanged:
    {
        if (withTime==true)
        {
            hours.visible=true
            minutes.visible=true
           // timeColumn.visible=true
        }
        else
        {
            hours.visible=false
            minutes.visible=false
           // timeColumn.visible=false
        }
    }
    GridLayout {



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
                SpinBox {
                    id: hours
                    x: 78
                    y: 18
                    height:30
                    width:100
                    onValueChanged:
                    {
                        grid.selectedDate.setHours(value);
                    }

                    from: 0
                    to:23
                }

                SpinBox {
                    id: minutes
                    x: 184
                    y: 18
                    height:30
                    onValueChanged:
                    {
                        grid.selectedDate.setMinutes(value);
                    }

                    width:100
                    from:0
                    to:59
                }


    }
    function getData() {
        if (withTime === true)
        {
           return grid.selectedDate.toLocaleString();
        }
        else
        {
            return grid.selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        }
        }
    function getDate()
    {
        return grid.selectedDate;
    }

    function updateData(value) {
        grid.selectedDate = value
        if (withTime === true)
        {
            hours.value=grid.selectedDate.getHours();
            minutes.value=grid.selectedDate.getMinutes();
        }
    }
}
