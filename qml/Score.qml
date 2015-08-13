/*
 * Score.qml
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

Page {
    id: page

    property real columnMinWidth: 0
    property real columnMaxWidth: Theme.itemSizeHuge

    property int _nTeams: teamModel.count
    property real _colWidth
    Binding {
        target: page
        property: "_colWidth"
        value: Math.min(Math.max(width / _nTeams, columnMinWidth), columnMaxWidth)
    }

    anchors.fill: parent

    ListModel {
        id: teamModel
        ListElement {
            label: "MP"
            score: 0
        }
        ListElement {
            label: "TND"
            score: 0
        }
        function setSummary(col, value) {
            this.get(col)['score'] = value
        }
    }
    ScoreModel {
        id: scoreModel
        nCols: page._nTeams
    }

    SilicaListView {
        id: scores
        width: parent.width
        height: parent.height - (toolbar.visible ? toolbar.height : 0.)
        contentWidth: page._nTeams * page._colWidth

        property var decorationFunc: undefined
        onDecorationFuncChanged: if (scores.decorationFunc !== undefined) {
            scores.decorationFunc()
        } else {
            scores.highlightNone()
        }
        function highlightHighest() {
            if (model === undefined) return
            var row, col
            for (row = 0; row < model.count - 1; row++) {
                var maxval = -1e99
                var obj = model.get(row)['values']
                for (col = 0; col < obj.count; col++) {
                    maxval = Math.max(obj.get(col)['value'], maxval)
                }
                for (col = 0; col < obj.count; col++) {
                    obj.get(col)['highlighted'] = (obj.get(col)['value'] == maxval)
                }
            }
        }
        function highlightNone() {
            if (model === undefined) return
            var row, col
            for (row = 0; row < model.count - 1; row++) {
                var obj = model.get(row)['values']
                for (col = 0; col < obj.count; col++) {
                    obj.get(col)['highlighted'] = false
                }
            }
        }

        property var summarizeFunc: sumUp
        function sumUp() {
            var row, col
            var sum = []
            for (col = 0; col < teamModel.count; col++) {
                sum[col] = 0.
            }
            for (row = 0; row < model.count - 1; row++) {
                var obj = model.get(row)['values']
                for (col = 0; col < obj.count; col++) {
                    sum[col] += obj.get(col)['value']
                }
            }
            for (col = 0; col < teamModel.count; col++) {
                teamModel.setSummary(col, sum[col])
            }
        }

        header: Column {
            width: page.width
            PageHeader {
                width: parent.width
                title: "Score"
            }
            Row {
                Repeater {
                    model: teamModel
                    Item {
                        width: page._colWidth
                        height: Theme.itemSizeExtraSmall
                        BackgroundItem {
                            width: parent.width - 2 * Theme.paddingSmall
                            height: parent.height
                            anchors.centerIn: parent
                            highlighted: true
                            highlightedColor: Theme.secondaryHighlightColor
                            
                            Label {
                                anchors.centerIn: parent
                                text: model.label
                                font.family: Theme.fontFamilyHeading
                                truncationMode: TruncationMode.Fade
                                color: Theme.highlightColor
                            }
                        }
                    }
                }
            }
        }

        function update() {
            /* Update highlight of results. */
            if (scores.decorationFunc !== undefined) scores.decorationFunc()
            /* Update summarize */
            if (scores.summarizeFunc !== undefined) scores.summarizeFunc()
        }
        
        property var teamModel: page.teamModel
        model: scoreModel
        Connections {
            target: scores.model
            onUpdated: scores.update()
        }

        property var edition: undefined
        function stopEdition() {
            if (edition) { edition.destroy() }
            edition = undefined
        }
        Component {
            id: editor
            RowEditor { }
        }

        delegate: RowItem {
            id: row
            colWidth: page._colWidth
            values: model.values
            index: model.index
            color: model.color
            editing: (scores.edition !== undefined &&
                      scores.edition.model === row.values)

            function deleteRow() {
                if (index > model.count - 2) return
                remorseAction("Deleting row",
                              function() { scores.model.removeAt(model) });
            }
            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: "Delete row"
                        onClicked: row.deleteRow()
                    }
                }
            }

            onClicked: {
                scores.stopEdition()
                scores.edition = editor.createObject(row,
                                                     {"model": values,
                                                      "scoreModel": scoreModel,
                                                      "colWidth": page._colWidth})
                scores.edition.closed.connect(scores.stopEdition)
            }
        }
    }
    OpacityRampEffect {
        enabled: toolbar.visible
        offset: 1. - 0.5 * toolbar.height / scores.height
        slope: scores.height / toolbar.height
        direction: OpacityRamp.TopToBottom
        sourceItem: scores
    }

    PanelBackground {
        id: toolbar
        visible: opacity > 0.
        opacity: scores.summarizeFunc === undefined ? 0. : 1.
        Behavior on opacity { FadeAnimation {} }

        anchors.bottom: parent.bottom
        width: page._nTeams * page._colWidth
        height: Theme.itemSizeSmall
        Row {
            Repeater {
                model: teamModel
                Item {
                    width: page._colWidth
                    height: toolbar.height
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 2. * Theme.paddingSmall
                        text: model.score
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                        color: Theme.highlightColor
                    }
                }
            }
        }
   }
}