import QtQuick
import QtQuick.Controls
Column {
    SpinBox {
        property var modelData
        stepSize: 1
        onValueChanged: updateColumnValue(modelData.columnName, value)
        function getData() {
            return value
        }

        function updateData(value) {
            console.log("SpinBox updateData called with value: " + value)
            value = parseInt(value)
        }
    }
}
