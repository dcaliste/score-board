/*
 * RowHeader.qml
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
    id: row
    property real colWidth
    property real colHeight: Theme.itemSizeExtraSmall
    property real fontSize: Theme.fontSizeMedium
    property bool highlighted: true
    property var model

    signal clicked(int index)

    Repeater {
        model: row.model
        Item {
            width: row.colWidth
            height: colHeight
            BackgroundItem {
                id: cell
                width: parent.width - Theme.paddingSmall
                height: parent.height
                anchors.centerIn: parent
                highlighted: down || row.highlighted
                Binding on highlightedColor {
                    target: cell
                    when: row.highlighted && !cell.down
                    value: Theme.secondaryHighlightColor
                }
                
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: model.label.length > 0 ? model.label : "Player " + (model.index + 1)
                    font.pixelSize: fontSize
                    font.family: Theme.fontFamilyHeading
                    truncationMode: TruncationMode.Fade
                    color: Theme.highlightColor
                }
                onClicked: row.clicked(model.index)
            }
        }
    }
}
