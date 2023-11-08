const express = require("express");
const next = require("next");

const Metrics = require("./metrics");

const hostname = "localhost";
const port = parseInt(process.env.PORT, 10) || 3000;

const nextApp = next({
    dev: false,
    hostname,
    port,
});

function App() {
    const app = express();
    app.all("*", nextApp.getRequestHandler());
    return app;
}

nextApp
    .prepare()
    .then(() => App().listen(port))
    .then(() => console.log(`app ready at http://${hostname}:${port}`))
    .then(() => Metrics().listen(9090))
    .then(() => console.log(`metrics ready at http://${hostname}:${9090}`))
    .catch(console.error);
