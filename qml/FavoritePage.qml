/*
 * FavoritePage.qml
 * Copyright (C) Damien Caliste 2016 <dcaliste@free.fr>
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
    property string title
    property alias model: list.model

    signal select(string value)

    SilicaListView {
        id: list

        anchors.fill: parent

        header: PageHeader {
            title: page.title
        }
        delegate: ListItem {
            id: row
            width: page.width
            contentHeight: Theme.itemSizeSmall
            Label {
                id: label
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                text: model.label
                color: row.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: page.select(label.text)
        }
    }
    VerticalScrollDecorator {
        flickable: list
    }
}
