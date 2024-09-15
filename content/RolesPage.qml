import QtQuick
import QtQuick.Controls

Item {
    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        /*TreeView {
                id: treeView
                anchors.fill: parent
                SplitView.preferredHeight: 250
                model: treeModel

                delegate: Item {
                    width: treeView.width
                    height: 40

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: styleData.selected ? "lightblue" : "white"

                        Row {
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: model.display
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    treeView.selectionModel.clearSelection()
                                    treeView.selectionModel.select(styleData.index, ItemSelectionModel.Rows | ItemSelectionModel.Select)
                                }
                            }
                        }
                    }
                }
                ListModel {
                        id: treeModel

                        ListElement {
                            display: "UserAccesses"
                            children: [
                                ListElement { display: "ViewLogs"; value: true },
                                ListElement { display: "ConfigureBackups"; value: true },
                                ListElement { display: "Reports"; value: true },
                                ListElement { display: "FreeQueries"; value: true },
                                ListElement { display: "ConfigureUser"; value: true }
                            ]
                        }

                        ListElement {
                            display: "TableAccesses"
                            children: [
                                Repeater {
                                    model: tablesModel
                                    delegate: ListElement {
                                        display: modelData.tableName
                                        children: [
                                            ListElement { display: "Add"; value: true },
                                            ListElement { display: "Edit"; value: true },
                                            ListElement { display: "Delete"; value: true }
                                        ]
                                    }
                                }
                            ]
                        }
                    }

                    ListModel {
                        id: tablesModel
                        ListElement { tableName: "Table1" }
                        ListElement { tableName: "Table2" }
                        // Добавьте другие таблицы по аналогии
                    }
            }

        Rectangle {
            id: tablePlaceholder
            x: 280
            y: 345
            width: 200
            height: 200
            color: "#ffffff"
        }*/
    }

}
