const express = require("express");
const cors = require("cors");

const app = express();
const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("climbs.db");

app.use(cors());
app.use(express.json());

app.post("/save", (req, res) =>
{
    console.log("SERVER RECEIVED DATA");

    db.run(
    `INSERT INTO climbInfo
    (Date, Type, Diameter, Duration)
    VALUES (?, ?, ?, ?)`,
    [
        req.body.date,
        req.body.treeType,
        req.body.treeWidth,
        req.body.time
    ]
    );

    console.log("Data saved to database!");
    res.send("Saved!");
});

app.get("/stats", (req, res) =>
{
    db.get(
        `
        SELECT
            COUNT(*) AS totalClimbs,
            COALESCE(SUM(Duration), 0) AS totalTime,
            COALESCE(MAX(Diameter), 0) AS biggestTree,
            COALESCE(SUM(Diameter), 0) AS totalDiameter
        FROM climbInfo
        `,
        [], 
        (err, row) =>
        {
            if (err)
            {
                res.status(500).send("Database error");
            }
            else
            {
                res.json(row);
            }
        }
    );
});

app.get("/climbs", (req, res) =>
{
    db.all(
        `
        SELECT *
        FROM climbInfo
        ORDER BY rowid DESC
        `,
        [],
        (err, rows) =>
        {
            if (err)
            {
                res.status(500).send("Database error");
            }
            else
            {
                res.json(rows);
            }
        }
    );
});

app.listen(3000, "0.0.0.0",() =>
{
    console.log("Backend running on port 3000");
});