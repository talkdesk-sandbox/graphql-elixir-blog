FROM ruby:2.4
LABEL maintainer="Rita Marques <@anaritamarques>"

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . ./

CMD ./client.rb
