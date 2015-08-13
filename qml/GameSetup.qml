/*
 * Score.qml
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

Page {
    id: page

    property var model
    signal accepted()

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
                model: page.model
                TextField {
                    width: Theme.itemSizeHuge * 2
                    height: Theme.itemSizeMedium
                    anchors.right: column.right
                    anchors.rightMargin: Theme.paddingLarge
                    placeholderText: "Player " + (model.index + 1)
                    label: placeholderText
                    onTextChanged: page.model.setTeamLabel(model.index, text)
                    Component.onCompleted: text = model.label
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: focus = false
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Start"
                onClicked: accepted()
            }
        }
        VerticalScrollDecorator { flickable: flickable }
    }
}