import QtQuick
import QtQuick.Controls

Column {
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
    }
}
