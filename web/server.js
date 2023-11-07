const express = require('express');
const next = require('next');
const {
    collectDefaultMetrics,
    Registry,
    Gauge,
} = require('prom-client');

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

function Metrics() {
    const app = express();
    const register = new Registry();

    collectDefaultMetrics({ register });

    // const players = new Gauge();

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
