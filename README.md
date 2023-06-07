# 🔥tokenbot

slack bot / social recognition platform

**project status:** code complete, not deployed

### features

- players send thanks to one or more players by mentioning this bot (`@thanks`) and other users in slack
- players may also receive bonus tokens according to [preset rules](engine/src/Rules.ml)
- web ui shows scoreboard and activity feed

### components
- engine: handles all business logic and interaction with db
- bot: listens for slack app mentions over websocket
- web: web app shows scoreboard, activity feed, rules, etc

### architecture
- db: redis
- auth: slack oauth
- engine: serverless binary compiled from ocaml
- bot: node.js thin client queues (bee-queue) incoming messages and pipes them to engine over stdin
- web: next.js 13 project uses app router

### running this project locally

- :warn: slack app must be provisioned in workspace
  - socket mode must be enabled
  - oauth must be enabled
  - required oauth scopes:
    - app_mentions:read
    - chat:write
    - reactions:write
    - users:read

- :warn: **must** have a way to serve local instance over https
  - because slack requires **https** oauth callback urls
  - could use [ngrok](https://ngrok.com/) - paid account works, free does not

- fork `.env.example` files into `.env`
- set app & bot tokens (from slack app) in `.env`
- set client id and secret (from slack app) in `.env`
- run `docker compose up`
- serve port 3000 over https
