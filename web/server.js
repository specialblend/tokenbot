const express = require('express');
const next = require('next');
const {
    collectDefaultMetrics,
    Registry,
    Gauge,
} = require('prom-client');
const Redis = require('ioredis');

const hostname = "localhost";
const port = parseInt(process.env.PORT, 10) || 3000;

const nextApp = next({
    dev: false,
    hostname,
    port,
});

function App() {
    const app = express();
    app.all('*', nextApp.getRequestHandler());
    return app;
}

async function scanKeys(pattern, db) {
    let cursor = null;
    const keys = [];
    while (cursor !== "0") {
        const [newCursor, foundKeys] = await db.scan(cursor, "MATCH", pattern);
        cursor = newCursor;
        keys.push(...foundKeys);
    }
    return keys;
}

async function scanJson(pattern, db) {
    const keys = await scanKeys(pattern, db);
    if (keys.length) {
        return db
            .mget(keys)
            .then((data) => data.filter(Boolean).map(JSON.parse.bind(JSON)));
    }
    return [];
}

function Metrics() {
    const app = express();
    const register = new Registry();

    const db = new Redis({
        host: process.env.REDIS_HOST || "localhost",
    })

    collectDefaultMetrics({ register });

    const players_gauge = new Gauge({
        name: "tokenbot_players",
        registers: [register],
        help: "players",
        labelNames: ["uid", "username"],
        async collect() {
            this.reset();

            const players = await scanJson("player:*", db)

            players.forEach(player => {
                this.labels({ uid: player.id, username: player.name, }).inc();
            });
        }
    });

    const tokens = new Gauge({
        name: "tokenbot_items",
        registers: [register],
        help: "player inventory",
        labelNames: ["token", "qty"],
        async collect() {

        }
    });

    const total_scores = new Gauge({
        name: "total_score",
        registers: [register],
        help: "player current score",
        labelNames: ["uid", "name"],
        async collect() {

        }
    });

    const high_scores = new Gauge({
        name: "high_score",
        registers: [register],
        help: "player all-time high score",
        labelNames: ["uid", "name"],
        async collect() {

        }
    });

    app.get("/metrics", async (req, res) => {
        res.set("Content-Type", register.contentType);
        res.end(await register.metrics())
    });

    return app;
}

nextApp
    .prepare()
    .then(() => App().listen(port))
    .then(() => console.log(`app ready at http://${hostname}:${port}`))
    .then(() => Metrics().listen(9090))
    .then(() => console.log(`metrics ready at http://${hostname}:${9090}`))
    .catch(console.error);
