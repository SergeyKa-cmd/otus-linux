FROM ruby:2.3.1-alpine

WORKDIR /app

COPY config.ru /app
COPY Gemfile /app

RUN bundle install --quiet

EXPOSE 9002

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8082"]