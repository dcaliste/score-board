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

Item {
    id: root

    property alias model: players.model
    property int index

    onIndexChanged: if (players.itemAt(index)) {
        players.itemAt(index).forceActiveFocus()
    }

    height: content.height

    ListModel {
        id: favorites
        Component.onCompleted: Storage.getPlayerList(storage, this)
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        Slider {
            id: nTeams
            width: parent.width
            minimumValue: 1
            maximumValue: 10
            stepSize: 1
            valueText: value
            label: "Number of players or teams of players"
            value: model.count
            onValueChanged: model.setNTeams(value)
            Connections {
                target: model
                onCountChanged: nTeams.value = model.count
            }
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
            Item {
                id: player
                property alias text: textField.text
                height: Theme.itemSizeMedium
                width: Theme.itemSizeHuge * 2
                anchors.horizontalCenter: content.horizontalCenter
                onActiveFocusChanged: if (activeFocus) {
                    root.index = model.index
                    textField.forceActiveFocus()
                }
                TextField {
                    id: textField
                    width: parent.width
                    placeholderText: "Player " + (model.index + 1)
                    label: placeholderText
                    onTextChanged: players.model.setTeamLabel(model.index, text)
                    onActiveFocusChanged: if (activeFocus) {
                        root.index = model.index
                    }
                    text: model.label
                    focus: root.index == model.index
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: if (root.index + 1 < root.model.count) {
                        root.index += 1
                    } else {
                        focus = false
                    }
                }
                IconButton {
                    id: favIcon
                    anchors.left: parent.right
                    icon.source: "image://theme/icon-m-favorite"
                    onClicked: {
                        var sel = pageStack.push("FavoritePage.qml", {
                            title: "Player " + (model.index + 1)
                            , model: favorites})
                        sel.select.connect(function(value) {
                            players.itemAt(root.index).text = value
                            if (root.index + 1 < root.model.count) {
                                root.index += 1
                            } else {
                                textField.focus = false
                            }
                            pageStack.pop()
                        })
                    }
                    visible: favorites.count > 0 && textField.focus
                }
            }
        }
    }
}
