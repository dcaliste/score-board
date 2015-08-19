/*
 * sqlite_backend.js
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

function getDB() {
    var db = LocalStorage.openDatabaseSync("score", "0.1",
                                           "Local storage for scores", 10000);
    return db;
}

/* Different tables. */
function createTableCategories(tx) {
    // Create the database if it doesn't already exist
    tx.executeSql('CREATE TABLE IF NOT EXISTS Categories(
                    category CHAR(128) NOT NULL)');
}

function createTableTeams(tx) {
    // Create the database if it doesn't already exist
    tx.executeSql('CREATE TABLE IF NOT EXISTS Teams(
                    board INT          NOT NULL,
                    label CHAR(128)    NOT NULL)');
}

function createTableHistory(tx) {
    // Create the database if it doesn't already exist
    tx.executeSql('CREATE TABLE IF NOT EXISTS History(
                    datetime INT          NOT NULL,
                    category INT                  )');
}

function createTableScores(tx) {
    // Create the database if it doesn't already exist
    tx.executeSql('CREATE TABLE IF NOT EXISTS Scores(
                    board INT             NOT NULL,
                    vals CHAR(1024)       NOT NULL)');
}

/* Get and set operations. */
function getBoardHistory(db, history, ordering) {
    history.clear();
    /* Must be synchronous here. */
    db.transaction(function(tx) {
        createTableCategories(tx);
        createTableTeams(tx);
        createTableHistory(tx);
        var rs = tx.executeSql('SELECT History.ROWID, datetime, (SELECT GROUP_CONCAT(CASE Length(Teams.label) WHEN 0 THEN "Player" ELSE Teams.label END, ", ") FROM Teams WHERE board = History.ROWID) teams, (SELECT Count(*) FROM Scores WHERE board = History.ROWID) nScores, Categories.category FROM History LEFT JOIN Categories ON History.category = Categories.ROWID ORDER BY datetime DESC');
        if (rs.rows.length > 0)
            for (var i = 0; i < rs.rows.length; i++) {
                var cpy = Object(rs.rows.item(i));
                var dateTime = new Date(cpy["datetime"] * 1000);
                cpy.section = Format.formatDate(dateTime, Formatter.TimepointSectionRelative);
                history.append(cpy);
            }
    });
}
function setBoardHistory(db, historyEntry, boardId) {
    db.transaction(function(tx) {
        createTableCategories(tx);
        createTableTeams(tx);
        createTableHistory(tx);
        var rs = tx.executeSql('SELECT History.ROWID, datetime, (SELECT GROUP_CONCAT(CASE Length(Teams.label) WHEN 0 THEN "Player" ELSE Teams.label END, ", ") FROM Teams WHERE board = History.ROWID) teams, (SELECT Count(*) FROM Scores WHERE board = History.ROWID) nScores, Categories.category FROM History LEFT JOIN Categories ON History.category = Categories.ROWID WHERE History.ROWID = ?', [boardId]);
        if (rs.rows.length > 0) {
            historyEntry['datetime'] = rs.rows.item(0).datetime
            historyEntry['teams'] = rs.rows.item(0).teams
            historyEntry['nScores'] = rs.rows.item(0).nScores
            historyEntry['category'] = rs.rows.item(0).category
        }
    });
}
function newBoard(db, teamModel, scoreModel) {
    var id
    db.transaction(function(tx) {
        createTableHistory(tx);
        var now = new Date()
        var row = [Math.round(now.getTime() / 1000),
                   0]
        var res = tx.executeSql('INSERT INTO History(datetime, category) VALUES (?, ?)', row);
        id = res.insertId;
    });
    return id;
}
function updateBoard(db, teamModel, scoreModel, boardId) {
    db.transaction(function(tx) {
        createTableHistory(tx);
        var row = [0,
                   boardId]
        var res = tx.executeSql('UPDATE History SET category = ? WHERE ROWID = ?', row);
    });
    return boardId;
}
function getBoardTeams(db, model, boardId) {
    db.transaction(function(tx) {
        createTableTeams(tx);
        var rs = tx.executeSql('SELECT label FROM Teams WHERE board = ?', [boardId]);
        if (rs.rows.length > 0) {
            model.clear();
            model.setNTeams(rs.rows.length);
            for (var i = 0; i < rs.rows.length; i++)
                model.setTeamLabel(i, rs.rows.item(i).label);
        }
    });
}
function setBoardTeams(db, model, boardId) {
    db.transaction(function(tx) {
        createTableTeams(tx);
        /* Erase all previous entries for this boardId. */
        tx.executeSql('DELETE FROM Teams WHERE board = ?', [boardId]);
        /* Insert new entries. */
        for (var i = 0; i < model.count; i++)
            tx.executeSql('INSERT INTO Teams(board, label) VALUES (?, ?)', [boardId, model.get(i)['label']]);
    });
}
function getBoardScores(db, model, boardId) {
    model.clearAll(false);
    db.transaction(function(tx) {
        createTableScores(tx);
        var rs = tx.executeSql('SELECT vals FROM Scores WHERE board = ?', [boardId]);
        if (rs.rows.length > 0)
            for (var i = 0; i < rs.rows.length; i++) {
                var row = model.addRow()
                var vals = rs.rows.item(i).vals.split(" ");
                for (var col in vals)
                    model.update(row, col, vals[col], false);
            }
    });
}
function setBoardScores(db, model, boardId) {
    db.transaction(function(tx) {
        createTableTeams(tx);
        /* Erase all previous entries for this boardId. */
        tx.executeSql('DELETE FROM Scores WHERE board = ?', [boardId]);
        /* Insert new entries. */
        for (var i = 0; i < model.count - 1; i++) {
            var row = model.get(i)['values']
            var scores = "" + row.get(0)['value']
            for (var col = 1; col < model.nCols; col++)
                scores += " " + row.get(col)['value']
            tx.executeSql('INSERT INTO Scores(board, vals) VALUES (?, ?)', [boardId, scores]);
        }
    });
}
function deleteBoard(db, boardId) {
    db.transaction(function(tx) {
        createTableHistory(tx);
        tx.executeSql('DELETE FROM History WHERE ROWID = ?', [boardId]);
        createTableTeams(tx);
        tx.executeSql('DELETE FROM Teams WHERE board = ?', [boardId]);
        createTableScores(tx);
        tx.executeSql('DELETE FROM Scores WHERE board = ?', [boardId]);
    });
}