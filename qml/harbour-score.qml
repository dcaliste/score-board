import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    initialPage: welcome
    cover: cover
    _defaultPageOrientations: Orientation.All

    property var scorePage: undefined

    Page {
        id: welcome
        Button {
            anchors.centerIn: parent
            text: "Start a new game"
            onClicked: scorePage = pageStack.push("Score.qml")
        }
    }

    CoverBackground {
        id: cover

        CoverActionList {
            enabled: (pageStack.depth == 1)
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: scorePage = pageStack.push("Score.qml")
            }
        }
        
        CoverActionList {
            enabled: (pageStack.depth > 1)
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: scorePage.addRow()
            }
        }
        
        Item {
            visible: pageStack.depth > 1
            width: parent.width - 2*Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingMedium

            Item {
                id: content
                anchors.fill: parent
                RowHeader {
                    model: scorePage !== undefined ? scorePage.teamModel : undefined
                    colWidth: model !== undefined ? parent.width / model.count : 1.
                    Component.onCompleted: console.log(model)
                }
            }
            
            Label {
                anchors.centerIn: parent
                text: "cover " + pageStack.depth
            }
            /*OpacityRampEffect {
                offset: 0.5
                direction: OpacityRamp.TopToBottom
                sourceItem: content
            }*/
        }

    }
}