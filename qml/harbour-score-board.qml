/*
 * harbour-score-board.qml
 * Copyright (C) Damien Caliste 2015-2016 <dcaliste@free.fr>
 *
 * score-board is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "sqlite_backend.js" as Storage

ApplicationWindow {
    id: app
    initialPage: welcome
    cover: cover
    _defaultPageOrientations: Orientation.All

    property var storage: Storage.getDB()

    property var scoreBoard: undefined
    function newScoreBoard() {
        var id = Storage.newBoard(storage)
        scoreBoard = pageStack.push("Score.qml", {'boardId': id})
        scoreBoard.commited.connect(function() {
            if (history.get(0)["rowid"] != id) {
                history.insert(0, {})
            }
            Storage.setBoardHistory(storage, history.get(0), id)
        })
    }

    ListModel {
        id: history
        Component.onCompleted: Storage.getBoardHistory(storage, this)
    }

    Page {
        id: welcome

        SilicaListView {
            anchors.fill: parent
            PullDownMenu {
                MenuItem {
                    text: "About"
                    onClicked: pageStack.push("About.qml")
                }
                MenuItem {
                    text: "Favorite board setup"
                    onClicked: pageStack.push("FavTeamPage.qml")
                }
                MenuItem {
                    text: "Start a new board"
                    onClicked: newScoreBoard()
                }
            }
            header: PageHeader {
                title: "Score keeping"
            }
            model: history
            ViewPlaceholder {
                enabled: history.count == 0
                text: "No stored boards"
            }
            section {
                property: 'section'

                delegate: SectionHeader {
                    text: section
                    height: Theme.itemSizeExtraSmall
                }
            }
            delegate: ListItem {
                id: row
                property int historyIndex: model.index !== undefined ? model.index : 0
                property int rowid: model.rowid !== undefined ? model.rowid : 0
                contentHeight: Theme.itemSizeMedium
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    anchors.bottom: parent.verticalCenter
                    color: row.highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.teams ? model.teams : "Undefined players"
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.top: parent.verticalCenter
                    text: model.category && model.category != ""
                          ? model.category + " (" + model.nScores + " scores)"
                          : model.nScores + " scores"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: row.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
                Label {
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.top: parent.verticalCenter
                    anchors.right: parent.right
                    text: Qt.formatDateTime(new Date(model.datetime * 1000), "dd/MM/yyyy hh:mm")
                    font.pixelSize: Theme.fontSizeExtraSmall;
                    color: row.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
                onClicked: {
                    scoreBoard = pageStack.push("Score.qml",
                                                {'boardId': model.rowid})
                    scoreBoard.commited.connect(function() {
                        Storage.setBoardHistory(storage, history.get(model.index), model.rowid)
                    })
                }
                function deleteBoard() {
                    remorseAction("Deleting board",
                                  function() {
                                      Storage.deleteBoard(storage, rowid)
                                      history.remove(historyIndex)
                                  });
                }
                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: "Delete board"
                            onClicked: row.deleteBoard()
                        }
                    }
                }
            }
        }
    }

    CoverBackground {
        id: cover

        CoverActionList {
            enabled: scoreBoard === undefined || scoreBoard === null
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: {
                    app.activate()
                    newScoreBoard()
                }
            }
        }

        Item {
            visible: scoreBoard === undefined || scoreBoard === null
            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge + Theme.paddingSmall
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.itemSizeSmall + Theme.paddingLarge

            Label {
                id: nBoards
                anchors.top: parent.top
                width: parent.width
                height: Theme.itemSizeExtraSmall
                color: Theme.highlightColor
                text: if (history.count == 0) {
                    return "No stored board yet"
                } else if (history.count == 1) {
                    return "1 board"
                } else {
                    return history.count + " boards"
                }
            }

            ListView {
                id: listHistory
                interactive: false
                width: parent.width
                height: parent.height - nBoards.height
                y: nBoards.height
                clip: true
                model: history
                delegate: ListItem {
                    contentHeight: Theme.itemSizeExtraSmall
                    Label {
                        width: parent.width
                        anchors.top: parent.top
                        font.pixelSize: Theme.fontSizeSmall
                        text: model.teams !== undefined ? model.teams : "undefined players"
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        text: model.nScores + " scores"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }
                }
            }
            OpacityRampEffect {
                enabled: true
                offset: 0.75
                direction: OpacityRamp.TopToBottom
                sourceItem: listHistory
            }

        }
        
        CoverActionList {
            enabled: scoreBoard !== undefined && scoreBoard !== null
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: {
                    app.activate()
                    scoreBoard.scoreModel.addRow()
                }
            }
        }
        
        Item {
            id: content
            visible: scoreBoard !== undefined && scoreBoard !== null
            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge + Theme.paddingSmall
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.itemSizeSmall + Theme.paddingLarge

            property real itemHeight: height / 7

            RowHeader {
                id: header
                model: scoreBoard !== undefined && scoreBoard !== null ? scoreBoard.teamModel : undefined
                colWidth: model !== undefined ? parent.width / Math.min(model.count, 4) : 1.
                colHeight: content.itemHeight
                fontSize: Theme.fontSizeSmall
            }
            Item {
                clip: true
                y: content.itemHeight + Theme.paddingSmall
                width: parent.width
                height: parent.height - y
                ListView {
                    id: list
                    interactive: false
                    width: parent.width
                    height: childrenRect.height - content.itemHeight
                    y: Math.min(parent.height - height, 0)
                    model: scoreBoard !== undefined && scoreBoard !== null ? scoreBoard.scoreModel : undefined
                    delegate: RowItem {
                        visible: model.index < list.model.count - 1
                        colWidth: header.colWidth
                        colHeight: content.itemHeight
                        fontSize: Theme.fontSizeSmall
                        values: model.values
                    }
                }
                OpacityRampEffect {
                    enabled: list.y < 0
                    slope: list.height / content.itemHeight
                    offset: 1. - (content.itemHeight - list.y) / list.height
                    direction: OpacityRamp.BottomToTop
                    sourceItem: list
                }
            }
        }

    }
}
