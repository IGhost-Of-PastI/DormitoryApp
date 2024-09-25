import QtQuick
import content
import QtQuick.Controls
Page {
    id: page

    Component.onCompleted:
    {
        var tables= MainSQLConnection.getAllTables();
        var views= MainSQLConnection.getAllViews();
        for (let i = 0;i<tables.length;i++)
        {
            comboboxTableModel.append({"display":tables[i]})
        }
      //  for (let j=0;j<views.length;j++)
      //  {
      //      comboboxTableModel.append({"display":views[j]})
      //  }
    }

    header: ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        ComboBox {
            id: comboBox
            model:ListModel
            {
                id:comboboxTableModel;
            }

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        ToolButton
        {
            id:viewButton
            text:"Просмотреть"
            onClicked:
            {
                table.tablename=comboBox.displayText;
            }
            anchors.left: comboBox.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        ToolButton
        {
            id:wordImport
            text:"Импорт в ворд"
            onClicked:
            {
                WordAndPrint.importInWord(table.tablename);
            }
            anchors.left: viewButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
     /*   ToolButton
        {
            id:printButton
            text:"Печать"
            onClicked:
            {
        //        WordAndPrint.printDoc();
            }
            anchors.left: wordImport.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }*/
    }

    Table {
        id: table
        tablename:comboBox.displayText;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

}
