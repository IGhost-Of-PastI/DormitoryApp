import QtQuick
import QtQuick.Controls
import content

Item {
    property string tablename;
    function getSelectedRowData(rowIndex) {
        var rowData = {}
        for (var i = 0; i < tableview.columns; i++) {
            var headerText = horizontalHeader.model.get(i).display
            var cellValue = tableview.model.data(tableview.model.index(
                                                     rowIndex, i))
            rowData[headerText] = cellValue
        }
        console.log(rowData)
    }

    HorizontalHeaderView {
        id: horizontalHeader
        height: 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: verticalHeader.width
        syncView: tableview
        boundsBehavior: Flickable.StopAtBounds
        clip: true
    }

    VerticalHeaderView {
        id: verticalHeader
        width: 75
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: horizontalHeader.height
        syncView: tableview
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        delegate: ItemDelegate {
            width: verticalHeader.width
            height: 40
            text: model.display

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tableview.selectionModel.clearSelection()
                    tableview.selectionModel.select(
                                tableview.model.index(index, 0),
                                ItemSelectionModel.Rows | ItemSelectionModel.Select)
                }
            }
        }
    }

    TableView {
        id: tableview

        anchors.fill: parent
        anchors.top: horizontalHeader.bottom
        anchors.left: verticalHeader.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 45
        anchors.leftMargin: 75
        columnSpacing: 5
        rowSpacing: 5
        boundsBehavior: Flickable.StopAtBounds
        resizableColumns: true

        ScrollBar.horizontal: ScrollBar {
            policy: "AsNeeded"
        }
        ScrollBar.vertical: ScrollBar {
            policy: "AsNeeded"
        }

        selectionModel: ItemSelectionModel {
            model: tableview.model
        }
        model: TableModel {
            id: model
            tablename: tablename
        }

        delegate: Row {
            required property bool selected
            property string tempText: model.display
            Rectangle {

                implicitHeight: parent.height
                implicitWidth: parent.width
                color: selected ? "blue" : "lightgray"

                TextField {
                    text: tempText
                    anchors.fill: parent
                    readOnly: true
                    onTextChanged: {
                        model.display = text
                    }
                }
            }
        }
    }
}