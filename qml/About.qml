/*
 * About.qml
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
    PageHeader {
        title: "About"
    }

    Column {
        anchors.centerIn: parent
        width: parent.width

        spacing: Theme.paddingLarge

        /*Image {
            source: Qt.resolvedUrl("../about-freebox-o-fish.png")
            anchors.horizontalCenter: parent.horizontalCenter
        }*/
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Score board"
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "a score sheet application"
            color: Theme.primaryColor
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
	    horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: Theme.fontSizeExtraSmall
            text: "Version 1.0\nCopyright © 2015 Damien Caliste\nemail : dcaliste@free.fr"
            color: Theme.secondaryColor
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
	    horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            text: "Score board is a Free software,\n" +
            "published under the \n" +
            "GNU General Public License v.3"
            color: Theme.secondaryColor
        }
    }
    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraSmall
        text: "https://github.com/dcaliste/score-board"
        color: Theme.secondaryColor
    }
}
