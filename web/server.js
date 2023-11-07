const express = require('express');
const next = require('next');

const hostname = "localhost";
const port = parseInt(process.env.PORT, 10) || 3000;

const nextApp = next({
    dev: false,
    hostname,
    port,
});

nextApp.prepare().then(() => {
    const appServer = express();
    appServer.all('*', nextApp.getRequestHandler());
    appServer.listen(port, () => {
        console.log(`app ready at http://localhost:${port}`);
    });
}).catch(console.error);
