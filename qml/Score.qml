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

    property int _nTeams: teamExample.count
    property real columnMinWidth: 0
    property real columnMaxWidth: Theme.itemSizeLarge * 2
    property real _colWidth
    Binding {
        target: page
        property: "_colWidth"
        value: Math.min(Math.max(width / _nTeams, columnMinWidth), columnMaxWidth)
    }

    anchors.fill: parent

    ListModel {
        id: teamExample
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
            scoreModel.append({'decoration': "none", 'color': "#aa222280", 'values': [{'value': 89}, {'value': 73}]})
            scoreModel.append({'decoration': "none", 'color': "transparent", 'values': [{'value': 0}, {'value': 162, 'highlighted': true}]})
            scoreModel.append({'decoration': "none", 'color': "transparent", 'values': [{'value': 24}, {'value': 138}]})
            scoreModel.append({})
        }
    }

    SilicaListView {
        id: scores
        anchors.fill: parent
        header: Column {
            width: page.width
            PageHeader {
                width: parent.width
                title: "Score"
            }
            Row {
                Repeater {
                    model: teamExample
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
                                truncationMode: TruncationMode.Fade
                                color: Theme.highlightColor
                            }
                        }
                    }
                }
            }
        }
            
        model: scoreModel
        property var edition: undefined

        function stopEdition() {
            if (edition) { edition.destroy() }
            edition = undefined
        }
        contentWidth: page._nTeams * page._colWidth

        Component {
            id: editor
            Row {
                id: line
                property int index
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
                        EnterKey.iconSource: "image://theme/icon-m-enter-close"
                        EnterKey.onClicked: line.closed()
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

            //color: model.color
            Row {
                opacity: (row.values !== undefined &&
                          (scores.edition === undefined ||
                           scores.edition.index != model.index)) ? 1. : 0.
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
                    }
                }
                Behavior on opacity { FadeAnimation {} }
            }
            IconButton {
                opacity: (row.values === undefined &&
                          (scores.edition === undefined ||
                           scores.edition.index != model.index)) ? 1. : 0.
                visible: opacity > 0.
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "image://theme/icon-m-add"
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
}