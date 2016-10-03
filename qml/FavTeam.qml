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

BoardSetup {
    model: teamModel

    TeamModel {
        id: teamModel
        Component.onCompleted: Storage.getBoardTeams(storage, teamModel, -1)
        //onUpdated: Storage.setBoardTeams(storage, teamModel, -1)
    }
}
