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
            onClicked: {
                var setup = pageStack.push("GameSetup.qml", {"model": teamModel})
                setup.accepted.connect(function() { pageStack.replace("Score.qml", {"teamModel": teamModel}) })
            }
        }
    }

    TeamModel {
        id: teamModel
    }
}