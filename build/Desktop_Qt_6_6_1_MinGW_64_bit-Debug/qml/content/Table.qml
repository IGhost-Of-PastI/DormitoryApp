import QtQuick
import QtQuick.Controls
import content

Item {
    id: root
    function refresh() {
        model.select()
    }

    signal selectionChanged(int newIndex)

    property string tablename
    property int currentSelected
    property alias tableModel: model

    function getSelectedRowData() {
        var rowData = []
        if (currentSelected !== undefined && currentSelected !== -1) {
            for (var i = 0; i < tableview.columns; i++) {
                var headerText = tableview.model.headerData(i, Qt.Horizontal, 0)
                var cellValue = tableview.model.data(tableview.model.index(
                                                         currentSelected, i))
                rowData.push({
                                 "columnName": headerText,
                                 "columnValue": cellValue
                             })
            }
            console.log(rowData)
            return rowData
        } else {
            console.log("No row is selected.")
            return null
        }
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
        delegate: ItemDelegate {
            text: model.display
        }
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
            text: model.display
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tableview.selectionModel.clearSelection()
                    tableview.selectionModel.select(
                                tableview.model.index(index, 0),
                                ItemSelectionModel.Rows | ItemSelectionModel.Select)
                    currentSelected = index
                    if (currentSelected !== -1) {
                        console.log("Selection changed, new row selected:",
                                    currentSelected)
                        // Emit your custom signal here
                        root.selectionChanged(currentSelected)
                    }
                }
            }
        }
    }


    /*Connections {
        target: tableview.selectionModel
        onCurrentRowChanged: {
            if (currentSelected !== -1) {
                console.log("Selection changed, new row selected:", currentSelected)
                // Emit your custom signal here
                root.selectionChanged(currentSelected)
            }
        }
    }*/
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

        selectionMode: TableView.SingleSelection
        selectionBehavior: TableView.SelectRows
        selectionModel: ItemSelectionModel {
            model: tableview.model
            id: selectionModel
        }

        ScrollBar.horizontal: ScrollBar {
            policy: "AsNeeded"
        }
        ScrollBar.vertical: ScrollBar {
            policy: "AsNeeded"
        }

        model: TableModel {
            id: model
            tablename: root.tablename
        }

        delegate: ItemDelegate {
            required property var model
            required property bool selected
            required property bool current
            highlighted: selected
            text: model.display
        }
    }
}
