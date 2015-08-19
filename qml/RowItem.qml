/*
 * RowItem.qml
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

ListItem {
    id: row

    property real colWidth
    property var values
    property int index
    property var color
    property bool editing

    contentHeight: Theme.itemSizeExtraSmall

    ListView.onAdd: AddAnimation { target: row; }
    ListView.onRemove: RemoveAnimation { target: row; }

    Rectangle {
        visible: row.color !== undefined
        anchors.fill: parent
        color: row.color !== undefined ? row.color : "background"
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        opacity: (row.values.get(0)['value'] !== undefined && !row.editing) ? 1. : 0.
        visible: opacity > 0.
        Repeater {
            model: row.values
            
            Item {
                width: row.colWidth
                height: row.height
                Label {
                    anchors.right: parent.right
                    anchors.rightMargin: 2 * Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.value ? model.value : "0"
                    color: model.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    visible: model.index == 0
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.index + 1
                    color: Theme.secondaryColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
        Behavior on opacity { FadeAnimation {} }
    }
    Image {
        anchors.top: parent.top
        opacity: (row.values.get(0)['value'] === undefined && !row.editing) ? 1. : 0.
        visible: opacity > 0.
        anchors.horizontalCenter: parent.horizontalCenter
        source: "image://theme/icon-m-add"
        Behavior on opacity { FadeAnimation {} }
    }
}