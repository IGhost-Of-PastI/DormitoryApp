import QtQuick
import QtQuick.Controls

Column {
    CheckBox {
        property var modelData
        function getData() {
            return checked
        }
        function updateData(value) {
            console.log("CheckBox updateData called with value: " + value)
            checked = (value === "true")
        }
    }
}
