import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    initialPage: welcome
    cover: null
    _defaultPageOrientations: Orientation.All

    Page {
        id: welcome
        Button {
            anchors.centerIn: parent
            text: "Start a new game"
            onClicked: pageStack.push("Score.qml")
        }
    }
}