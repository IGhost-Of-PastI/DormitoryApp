import QtQuick 6.2
import content

Image {
    id: backImage

    anchors.fill: parent
    //source: "file"

    LoginPanel{
        anchors.bottom: parent.bottom;
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
    }
}
