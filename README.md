# README #

This provides an Ubuntu 18.04 base build of Ruby from source (using ruby-build) with jemalloc.

The default `RUBY_VERSION` is Ruby 2.7.2.
The default `BUNDLER_VERSION` is Bundler 2.2.15

## Building Ruby 2.7.2

```bash
docker build -t mediapingllc/ruby-jemalloc:2.7.2 .
```

## Building Ruby 2.5

```bash
docker build -t mediapingllc/ruby-jemalloc:2.5.8 --build-arg RUBY_VERSION=2.5.8 --build-arg BUNDLER_VERSION=1.17.3 .
```

## Building Ruby 2.4

```bash
docker build -t mediapingllc/ruby-jemalloc:2.4.10 --build-arg RUBY_VERSION=2.4.10 --build-arg BUNDLER_VERSION=1.17.3 .
```

## Using

Sample Dockerfile to use either version image:

```bash
FROM mediapingllc/ruby-jemalloc:2.5.8

ARG RUBY_VERSION=2.5.8
ARG BUNDLER_VERSION=1.17.3
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y libmysqlclient-dev && \
    apt-get auto-remove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

EXPOSE 3000

WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN gem install bundler -v=${BUNDLER_VERSION} && \
    bundle install --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3;

COPY . /app

# start the app
CMD ["bundle", "exec", "rails", "server"]
```
