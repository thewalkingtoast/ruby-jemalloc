# README #

This provides an Ubuntu 20.04 base build of Ruby from source (using ruby-build) with jemalloc.

The default `RUBY_VERSION` is Ruby 2.6.10.

## Building Ruby 2.6

```bash
docker build -t mediapingllc/ruby-jemalloc:2.6.10 .
```

## Building Ruby 2.5

```bash
docker build -t mediapingllc/ruby-jemalloc:2.5.9 --build-arg RUBY_VERSION=2.5.9 .
```

## Building Ruby 2.4

```bash
docker build -t mediapingllc/ruby-jemalloc:2.4.10 --build-arg RUBY_VERSION=2.4.10 .
```

## Using

Sample Dockerfile:

```bash
FROM mediapingllc/ruby-jemalloc:2.6.10

ARG RUBY_VERSION=2.6.10
ARG BUNDLER_VERSION=1.17.3
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y libmysqlclient-dev && \
    apt-get auto-remove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

EXPOSE 3000

WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN gem install bundler && \
    bundle install --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3;

COPY . /app

# start the app
CMD ["bundle", "exec", "rails", "server"]
```
