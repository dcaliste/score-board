/*
 * RowEditor.qml
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

Row {
    id: line

    property real colWidth
    property var scoreModel
    property var model

    signal closed()

    opacity: 0.
    Repeater {
        model: line.model.count > 0 ? line.model : scoreModel.nCols
        TextField {
            width: colWidth
            text: model.value ? model.value : ""
            inputMethodHints: Qt.ImhDigitsOnly
            Component.onCompleted: if (model.index == 0) { forceActiveFocus() }
            Component.onDestruction: scoreModel.update(line.model, model.index, text)
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: line.closed()
        }
        Component.onDestruction: if (line.model.count == 0) {
            line.model = scoreModel.addRow()
        }
    }
    Component.onCompleted: opacity = 1.
    Behavior on opacity { FadeAnimation {} }
}
