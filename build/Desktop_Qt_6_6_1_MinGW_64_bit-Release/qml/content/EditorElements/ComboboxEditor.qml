import QtQuick
import QtQuick.Controls
import content

Column {
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
    }
}
