# 🔥 tokenbot

slack bot / social recognition platform

### 🚀 .env config

```dotenv
# engine/.env
SLACK_BOT_TOKEN="xoxb-example"
```

```dotenv
# bot/.env
SLACK_APP_TOKEN="xapp-example"
SLACK_BOT_TOKEN="xoxb-example"
```

```dotenv
# web/.env
NEXTAUTH_SECRET=changeme
NEXTAUTH_URL="https://example123.ngrok/api/auth"

SLACK_BOT_TOKEN="xoxb-example"
SLACK_CLIENT_ID=example
SLACK_CLIENT_SECRET=example
SLACK_TEAM_ID=example
```

### 📦 run inside docker

```bash
# build and run container
docker compose build
docker compose up

# serve app over https
ngrok http 3000 --domain example123.ngrok.io

# access web app
open https://example123.ngrok.io/
```

### 🔥 local dev

```bash
# https://docs.docker.com/compose/
cd dev

# start redis
docker compose up
````

```bash
# https://ocaml.org/docs/up-and-running
cd engine

# setup opam environment
opam switch create 5.0.0  
eval $(opam env --switch=5.0.0)

# install dependencies
opam install -y --deps-only .

# build project
dune build

# run tests
dune test

```

```bash
# https://nodejs.dev/en/learn/how-to-install-nodejs/
cd bot

# install dependencies
npm install

# start slack bot
npm run dev

```

```bash
# https://nextjs.org/docs
cd web

# install dependencies
npm install

# start web app
npm run dev
```
