FROM node:alpine AS root
WORKDIR tokenbot

FROM root AS bot

RUN apk add --no-cache git
ADD bot bot
RUN cd bot && npm ci --omit=dev

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

COPY --from=bot /tokenbot/bot/node_modules ./node_modules
COPY --from=bot /tokenbot/bot/main.js ./main.js
COPY --from=ocaml_build /home/opam/engine/_build/default/bin/tokenbot.exe ./tokenbot.exe

RUN addgroup -S tokenbot && adduser -S tokenbot -G tokenbot
USER tokenbot

CMD ["node", "main.js"]

