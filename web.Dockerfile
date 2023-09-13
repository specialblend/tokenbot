FROM node:alpine AS root
WORKDIR tokenbot

FROM root AS web_deps
RUN apk add --no-cache git
ADD web/package.json ./web/package.json
ADD web/package-lock.json ./web/package-lock.json
RUN cd web && npm ci

FROM web_deps AS web_build
ADD web web
RUN cd web && NODE_ENV=production npm run build && npm ci --omit=dev

FROM ocaml/opam:alpine AS ocaml
USER root
RUN opam init --disable-sandboxing

FROM ocaml AS ocaml_dev
ADD engine/tokenbot.opam ./engine/tokenbot.opam
RUN apk add gmp-dev
RUN cd engine && opam install -y --deps-only .

FROM ocaml_dev AS ocaml_build
ADD engine engine
RUN cd engine && \
    eval $(opam env) && \
    dune build && \
    dune test

FROM root AS final
RUN apk add gmp-dev

COPY --from=web_build /tokenbot/web/node_modules ./node_modules
COPY --from=web_build /tokenbot/web/package.json .
COPY --from=web_build /tokenbot/web/next.config.js .
COPY --from=web_build /tokenbot/web/.next ./.next
COPY --from=web_build /tokenbot/web/public ./public
COPY --from=ocaml_build /home/opam/engine/_build/default/bin/tokenbot.exe ./bin/tokenbot.exe

RUN addgroup -S tokenbot && adduser -S tokenbot -G tokenbot
USER tokenbot

CMD ["npm", "start"]
