/*
 * Score.qml
 * Copyright (C) Damien Caliste 2015-2016 <dcaliste@free.fr>
 *
 * score-board is free software: you can redistribute it and/or modify it
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

    property int boardId: 0
    onBoardIdChanged: if (boardId > 0) {
        Storage.getBoardTeams(storage, teamModel, boardId)
        Storage.getBoardScores(storage, scoreModel, boardId)
    }

    signal commited()

    property alias teamModel: teamModel
    property alias scoreModel: scoreModel

    property real columnMinWidth: 0
    property real columnMaxWidth: Theme.itemSizeHuge

    property var _setup: undefined
    property int _nTeams: teamModel.count
    property real _colWidth
    Binding {
        target: page
        property: "_colWidth"
        value: Math.min(Math.max(scores.width / _nTeams, columnMinWidth), columnMaxWidth)
    }

    TeamModel {
        id: teamModel
    }
    ScoreModel {
        id: scoreModel
        nCols: teamModel.count
    }
    onStatusChanged: if (boardId > 0 && status == PageStatus.Inactive) {
        Storage.setBoardTeams(storage, teamModel, boardId)
        Storage.setBoardScores(storage, scoreModel, boardId)
        commited()
    }
    Connections {
        target: Qt.application
        onAboutToQuit: if (boardId > 0) {
            Storage.setBoardTeams(storage, teamModel, boardId)
            Storage.setBoardScores(storage, scoreModel, boardId)
        }
    }

    SilicaListView {
        id: scores
        anchors.horizontalCenter: parent.horizontalCenter
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
        onSummarizeFuncChanged: if (scores.summarizeFunc !== undefined) {
            scores.summarizeFunc()
        }
        function sumUp() {
            var row, col
            var sum = []
            for (col = 0; col < teamModel.count; col++) {
                sum[col] = 0.
            }
            for (row = 0; row < scoreModel.count - 1; row++) {
                var obj = scoreModel.get(row)['values']
                for (col = 0; col < obj.count; col++) {
                    sum[col] += obj.get(col)['value']
                }
            }
            for (col = 0; col < teamModel.count; col++) {
                teamModel.setSummary(col, sum[col])
            }
        }

        PullDownMenu {
            MenuItem {
                text: scores.decorationFunc === undefined
                      ? "Highlight highest" : "No highlight"
                onClicked: scores.decorationFunc = scores.decorationFunc === undefined
                           ? scores.highlightHighest : undefined
            }
            MenuItem {
                text: scores.summarizeFunc === undefined
                      ? "Sum up scores" : "No summarize"
                onClicked: scores.summarizeFunc = scores.summarizeFunc === undefined
                           ? scores.sumUp : undefined
            }
            MenuItem {
                text: "Modify the setup"
                onClicked: {
                    if (_setup === undefined) {
                        _setup = pageStack.pushAttached("BoardSetup.qml",
                                                        {'model': teamModel})
                    }
                    pageStack.navigateForward()
                }
            }
            MenuItem {
                text: "Restart this board"
                onClicked: scoreModel.clearAll()
            }
        }

        header: Column {
            width: page.width
            PageHeader {
                width: parent.width
                title: "Score"
            }
            RowHeader {
                colWidth: page._colWidth
                model: teamModel
                onClicked: {
                    if (_setup === undefined) {
                        _setup = pageStack.pushAttached("BoardSetup.qml",
                                                        {'model': teamModel,
                                                         'index': index})
                    } else {
                        _setup.index = index
                    }
                    pageStack.navigateForward()
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
            addButton: model.last
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
                                                      "colWidth": page._colWidth,
                                                      "newRow": row.addButton})
                scores.edition.closed.connect(scores.stopEdition)
            }
        }
        VerticalScrollDecorator { flickable: scores }
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
