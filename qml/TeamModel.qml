/*
 * TeamModel.qml
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

ListModel {
    // Two teams by default
    Component.onCompleted: setNTeams(2)
    function setNTeams(n) {
        var i
        for (i = this.count - 1; i >= n ; i--) {
            this.remove(i)
        }
        for (i = this.count; i < n; i++) {
            this.append({'label': "", 'score': 0})
        }
    }
    function setTeamLabel(col, label) {
        this.get(col)['label'] = label
    }
    function setSummary(col, value) {
        this.get(col)['score'] = value
    }
}
