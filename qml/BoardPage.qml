/*
 * BoardPage.qml
 * Copyright (C) Damien Caliste 2015-2016 <dcaliste@free.fr>
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

    property alias model: board.model
    property alias index: board.index
    property string category

    onStatusChanged: if (status == PageStatus.Inactive) category = label.text

    ListModel {
        id: categories
        Component.onCompleted: Storage.getCategoryList(storage, this)
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
            Item {
                width: parent.width
                height: Theme.itemSizeMedium
                TextField {
                    id: label
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: favIcon.left
                    anchors.rightMargin: Theme.paddingSmall

                    placeholderText: "Game name"
                    text: page.category

                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: focus =  false
                }
                IconButton {
                    id: favIcon
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    icon.source: "image://theme/icon-m-favorite"
                    onClicked: {
                        var sel = pageStack.push("FavoritePage.qml", {
                            title: "Game", model: categories})
                        sel.select.connect(function(value) {
                            page.category = value
                            pageStack.pop()
                        })
                    }
                    visible: categories.count > 0 && label.focus
                }
            }
            BoardSetup {
                id: board
                width: parent.width
            }
        }
        VerticalScrollDecorator { flickable: flickable }
    }
}
