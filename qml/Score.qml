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
    }
    ListModel {
        id: scoreModel
        Component.onCompleted: {
            scoreModel.append({'color': "#80aa2222", 'values': [{'value': 89}, {'value': 73}]})
            scoreModel.append({'values': [{'value': 0}, {'value': 162}]})
            scoreModel.append({'values': [{'value': 24}, {'value': 138}]})
            scoreModel.append({})
            updated()
        }
        signal updated()
        function removeAt(row) {
            this.remove(row['index'])
            updated()
        }
        function addRow() {
            var scores = []
            var i
            for (i = 0; i < page._nTeams; i++) {
                scores[i] = {'value': 0}
            }
            this.insert(this.count - 1, {'values': scores})
            return this.get(this.count - 2)['values']
        }
        function update(row, col, value) {
            var fval = value.length > 0 ? parseFloat(value) : 0.
            if (fval != row.get(col)['value']) {
                row.get(col)['value'] = fval
                updated()
            }
        }
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
                teamModel.get(col)['score'] = sum[col]
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
            Row {
                id: line
                property var model
                signal closed()
                opacity: 0.
                Repeater {
                    model: line.model ? line.model : page._nTeams
                    TextField {
                        width: page._colWidth
                        text: model.value ? model.value : ""
                        inputMethodHints: Qt.ImhDigitsOnly
                        Component.onCompleted: if (model.index == 0) { forceActiveFocus() }
                        Component.onDestruction: scoreModel.update(line.model, model.index, text)
                        EnterKey.iconSource: "image://theme/icon-m-enter-close"
                        EnterKey.onClicked: line.closed()
                    }
                    Component.onDestruction: if (line.model === undefined) {
                        line.model = scoreModel.addRow()
                    }
                }
                Component.onCompleted: opacity = 1.
                Behavior on opacity { FadeAnimation {} }
            }
        }

        delegate: ListItem {
            id: row
            contentHeight: Theme.itemSizeExtraSmall
            property var values: model.values
            property int index: model.index

            function deleteRow() {
                if (index > model.count - 2) return
                remorseAction("Deleting row", function() { scores.model.removeAt(model) });
            }
            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: "Delete row"
                        onClicked: row.deleteRow()
                    }
                }
            }
            ListView.onAdd: AddAnimation { target: row; }
            ListView.onRemove: RemoveAnimation { target: row; }

            Rectangle {
                visible: model.color !== undefined
                anchors.fill: parent
                color: model.color !== undefined ? model.color : "background"
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                opacity: (row.values !== undefined &&
                          (scores.edition === undefined ||
                           scores.edition.model !== row.values)) ? 1. : 0.
                visible: opacity > 0.
                Repeater {
                    model: row.values
                    
                    Item {
                        width: page._colWidth
                        height: row.height
                        Label {
                            anchors.right: parent.right
                            anchors.rightMargin: 2 * Theme.paddingSmall
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.value
                            color: model.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            visible: model.index == 0
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.paddingSmall
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.index + 1
                            color: Theme.secondaryColor
                            font.italic: true
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
                Behavior on opacity { FadeAnimation {} }
            }
            Image {
                anchors.top: parent.top
                opacity: (row.values === undefined &&
                          (scores.edition === undefined ||
                           scores.edition.model !== row.values)) ? 1. : 0.
                visible: opacity > 0.
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/icon-m-add"
                Behavior on opacity { FadeAnimation {} }
            }
            onClicked: {
                scores.stopEdition()
                scores.edition = editor.createObject(row, {"model": values,
                                                           "index": model.index})
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