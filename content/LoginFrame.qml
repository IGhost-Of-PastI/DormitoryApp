import QtQuick 6.2

Image {
    id: backImage
    source: "file"

    LoginPanel{
        anchors.bottom: parent.bottom;
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
    }
}
