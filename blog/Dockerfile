FROM elixir:1.6.5

RUN apt-get update \
  && apt-get install -y inotify-tools nodejs \
  && curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /usr/local/bin/wait-for-it \
  && chmod +x /usr/local/bin/wait-for-it \
  && ln -s /usr/bin/nodejs /usr/bin/node

RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

WORKDIR /app
COPY mix.* ./
RUN mix do deps.get, compile

COPY . ./

CMD ["/app/entrypoint.sh"]
