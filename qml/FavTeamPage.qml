/*
 * FavTeam.qml
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
import "sqlite_backend.js" as Storage

Page {
    id: page

    property int _boardId: -1

    TeamModel {
        id: teamModel
        Component.onCompleted: Storage.getBoardTeams(storage, teamModel, _boardId)
    }

    onStatusChanged: if (status == PageStatus.Inactive) {
        Storage.setBoardTeams(storage, teamModel, _boardId)
    }
    Connections {
        target: Qt.application
        onAboutToQuit: Storage.setBoardTeams(storage, teamModel, _boardId)
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                title: "Favorite board setup"
            }
            BoardSetup {
                model: teamModel
                width: parent.width
            }
        }
        VerticalScrollDecorator { flickable: flickable }
    }
}
