FROM elixir:1.16-otp-24-alpine as elixir-builder

ENV MIX_ENV=prod

RUN mix local.rebar --force \
    && mix local.hex --force

WORKDIR /app

COPY lib ./lib
COPY config ./config
COPY rel ./rel
COPY mix.exs .
COPY mix.lock .

RUN mix deps.get --only $MIX_ENV

RUN mix deps.compile

RUN mix release ddogzip

FROM alpine:3.17 as ddogzip

RUN apk add --no-cache \
      ncurses \
      openssl

WORKDIR "/app"
RUN chown nobody /app

COPY --from=elixir-builder --chown=nobody:root /app/_build/prod/rel/ddogzip /app
USER nobody
CMD ["/app/bin/ddogzip", "start"]

