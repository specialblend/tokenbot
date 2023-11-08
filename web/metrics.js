const Redis = require("ioredis");

const {
    Registry,
    Gauge,
} = require("prom-client");

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

    function scanPlayers() {
        return scanJson("player:*", db);
    }

    void new Gauge({
        name: "tokenbot_players",
        registers: [register],
        help: "players",
        labelNames: ["uid", "username"],
        async collect() {
            this.reset();
            const players = await scanPlayers();
            players.forEach(player => {
                this.labels({ uid: player.id, username: player.name, }).inc();
            });
        }
    });

    void new Gauge({
        name: "tokenbot_items",
        registers: [register],
        help: "player inventory",
        labelNames: ["token", "uid"],
        async collect() {
            this.reset();
            const players = await scanPlayers();
            players.forEach(player => {
                player.items.forEach(([token, qty]) => {
                    const uid = player.id;
                    this.labels({ token, uid }).inc(qty);
                })
            });
        }
    });

    void new Gauge({
        name: "tokenbot_current_score",
        registers: [register],
        help: "player current score",
        labelNames: ["uid", "name", "score_type"],
        async collect() {
            this.reset();
            const players = await scanPlayers();
            players.forEach(player => {
                this.labels({
                    uid: player.id,
                    name: player.name,
                    score_type: "base"
                }).set(player.score.base)

                this.labels({
                    uid: player.id,
                    name: player.name,
                    score_type: "bonus"
                }).set(player.score.bonus)

                this.labels({
                    uid: player.id,
                    name: player.name,
                    score_type: "total"
                }).set(player.score.total)
            });
        }
    });

    void new Gauge({
        name: "tokenbot_high_score",
        registers: [register],
        help: "player all-time high score",
        labelNames: ["uid", "name"],
        async collect() {
            this.reset();
            const players = await scanPlayers();
            players.forEach(player => {
                this.labels({
                    uid: player.id,
                    name: player.name,
                }).set(player.highscore)
            });
        }
    });

    app.get("/metrics", async (req, res) => {
        res.set("Content-Type", register.contentType);
        res.end(await register.metrics())
    });

    return app;
}

module.exports = Metrics;