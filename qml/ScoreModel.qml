/*
 * ScoreModel.qml
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
    property int nCols
    onNColsChanged: {
        var row, col
        for (row = 0; row < this.count - 1; row++) {
            // Adjust the number of column to exactly nCols
            var obj = this.get(row)['values']
            if (nCols < obj.count) obj.remove(nCols, obj.count - nCols)
            for (col = obj.count; col < nCols; col++) {
                obj.append({'value': 0})
            }
        }
    }
    Component.onCompleted: {
        /* scoreModel.append({'color': "#80aa2222", 'values': [{'value': 89}, {'value': 73}]})
           scoreModel.append({'values': [{'value': 0}, {'value': 162, 'highlighted': true}]})
           scoreModel.append({'values': [{'value': 24}, {'value': 138}]}) */
        ensureLastRow()
        updated()
    }
    signal updated()
    function ensureLastRow() {
        if (this.count > 0 && this.get(this.count - 1)['last']) return
        this.append({'last': true, 'values': []})
    }
    function removeAt(row) {
        this.remove(row['index'])
        updated()
    }
    function clearAll(signal) {
        ensureLastRow()
        if (this.count == 1) return
        this.remove(0, this.count - 1)
        if (signal === undefined || signal) updated()
    }
    function addRow() {
        var scores = []
        var i
        for (i = 0; i < nCols; i++) {
            scores[i] = {'value': 0, 'highlighted': false}
        }
        ensureLastRow()
        this.insert(this.count - 1, {'values': scores, 'last': false})
        return this.get(this.count - 2)['values']
    }
    function update(row, col, value, signal) {
        var fval = value.length > 0 ? parseFloat(value) : 0.
        if (fval != row.get(col)['value']) {
            row.get(col)['value'] = fval
            if (signal === undefined || signal) updated()
        }
    }
}
