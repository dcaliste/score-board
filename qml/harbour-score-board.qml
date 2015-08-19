/*
 * harbour-score-board.qml
 * Copyright (C) Damien Caliste 2015 <dcaliste@free.fr>
 *
 * freebox-o-fish is free software: you can redistribute it and/or modify it
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
    initialPage: welcome
    cover: cover
    _defaultPageOrientations: Orientation.All

    property var storage: Storage.getDB()

    property var scoreBoard: undefined
    function newScoreBoard() {
        history.insert(0, {})
        scoreBoard = pageStack.push("Score.qml", {'historyEntry': history.get(0)})
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
                property int rowid: model.rowid
                contentHeight: Theme.itemSizeSmall
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.teams ? model.teams : "Undefined players"
                    truncationMode: TruncationMode.Fade
                    width: parent.width - 2 * Theme.paddingSmall
                }
                Column {
                    id: column
                    property var color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingSmall
                    Label {
                        anchors.right: parent.right
                        color: column.color
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: model.nScores + " scores"
                    }
                    Label {
                        color: column.color
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: Qt.formatDateTime(new Date(model.datetime * 1000), "dd/MM/yyyy hh:mm")
                    }
                }
                onClicked: scoreBoard = pageStack.push("Score.qml",
                                                      {'boardId': model.rowid,
                                                       'historyEntry': history.get(model.index)})
                function deleteBoard() {
                    remorseAction("Deleting board",
                                  function() {
                                      history.remove(model['index'])
                                      Storage.deleteBoard(storage, rowid)
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
            enabled: (pageStack.depth == 1)
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: newScoreBoard()
            }
        }
        
        CoverActionList {
            enabled: (pageStack.depth > 1)
            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: scoreBoard.addRow()
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
                    model: scoreBoard !== undefined && scoreBoard !== null ? scoreBoard.teamModel : undefined
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