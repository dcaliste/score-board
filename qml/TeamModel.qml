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
    ListElement {
        label: ""
        score: 0
    }
    ListElement {
        label: ""
        score: 0
    }
    signal updated()
    function setNTeams(n) {
        if (n == this.count) return
        if (n < this.count) this.remove(n, this.count - n)
        var i
        for (i = this.count; i < n; i++) {
            this.append({'label': "", 'score': 0})
        }
        this.updated()
    }
    function setTeamLabel(col, label) {
        if (label == this.get(col)['label']) return
        this.get(col)['label'] = label
        this.updated()
    }
    function setSummary(col, value) {
        this.get(col)['score'] = value
    }
}
