FROM elixir:1.16-otp-24-alpine as elixir-builder


ENV MIX_ENV=prod

RUN mix local.rebar --force \
    && mix local.hex --force

WORKDIR /app

COPY mix.exs ./
COPY mix.lock ./

RUN mix deps.get --only $MIX_ENV

COPY lib lib
COPY config config
COPY rel rel

RUN mix deps.compile

COPY version.txt ./

RUN mix compile

RUN mix release ddogzip

FROM alpine:3.18 as ddogzip

LABEL org.opencontainers.image.source=https://github.com/luisgabrielroldan/ddogzip
LABEL org.opencontainers.image.description="Datadog to Zipking collector"
LABEL org.opencontainers.image.licenses=MIT

RUN apk add --no-cache \
      ncurses \
      openssl

WORKDIR "/app"
RUN chown nobody /app

COPY --from=elixir-builder --chown=nobody:root /app/_build/prod/rel/ddogzip /app

USER nobody

CMD ["/app/bin/ddogzip", "start"]

