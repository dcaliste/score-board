/*
 * BoardSetup.qml
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
import "sqlite_backend.js" as Storage

Page {
    id: page

    property var model
    property int index
    signal accepted()

    onIndexChanged: if (players.itemAt(index)) {
        players.itemAt(index).forceActiveFocus()
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column
            width: page.width
            PageHeader {
                title: "Board setup"
            }
            Slider {
                id: nTeams
                width: parent.width
                minimumValue: 1
                maximumValue: 10
                stepSize: 1
                valueText: value
                label: "Number of players or teams of players"
                onValueChanged: model.setNTeams(value)
                Component.onCompleted: value = model.count
            }
            Item {
                width: parent.width
                height: Theme.itemSizeMedium
                Label {
                    anchors.centerIn: parent
                    text: "Label for each player / team"
                    color: Theme.highlightColor
                }
            }
            Repeater {
                id: players
                model: page.model
                Item {
                    id: player
                    property alias text: textField.text
                    height: Theme.itemSizeMedium + (favorites.parent == player ? favorites.height : 0.)
                    width: Theme.itemSizeHuge * 2
                    anchors.horizontalCenter: column.horizontalCenter
                    onActiveFocusChanged: if (activeFocus) {
                        page.index = model.index
                        textField.forceActiveFocus()
                    }
                    TextField {
                        id: textField
                        width: parent.width
                        placeholderText: "Player " + (model.index + 1)
                        label: placeholderText
                        onTextChanged: page.model.setTeamLabel(model.index, text)
                        onActiveFocusChanged: if (activeFocus) {
                            page.index = model.index
                        }
                        text: model.label
                        focus: page.index == model.index
                        EnterKey.iconSource: "image://theme/icon-m-enter-close"
                        EnterKey.onClicked: focus = false
                    }
                    IconButton {
                        id: favIcon
                        anchors.left: parent.right
                        icon.source: "image://theme/icon-m-favorite"
                        onClicked: favorites.show(player)
                        visible: favorites.count > 0
                                 && (textField.focus || favorites.parent == player)
                    }
                }
            }
        }
        VerticalScrollDecorator { flickable: flickable }
    }

    ContextMenu {
        id: favorites
        property int count: favRepeater.model !== undefined ? favRepeater.model.length : 0
        Repeater {
            id: favRepeater
            model: Storage.getPlayerList(storage)

            MenuItem {
                text: modelData
                onClicked: players.itemAt(page.index).text = text
            }
        }
    }
}
