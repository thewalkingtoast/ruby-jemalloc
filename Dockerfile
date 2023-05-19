FROM ubuntu:focal

LABEL maintainer="Adam Radabaugh <adam@mediaping.net>"

ARG RUBY_VERSION=2.5.9
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# container dependencies
RUN apt-get update &&  apt-get upgrade -y && apt-get install -y autoconf \
  bison \
  build-essential \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm6 \
  libgdbm-dev \
  libdb-dev \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  libjemalloc-dev \
  tzdata \
  wget;

# skip installing gem documentation
RUN set -eux; \
  mkdir -p /usr/local/etc; \
  { \
  echo 'install: --no-document'; \
  echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc

# build ruby
RUN git clone https://github.com/rbenv/ruby-build.git; \
  ./ruby-build/install.sh; \
  CONFIGURE_OPTS=--with-jemalloc ruby-build $RUBY_VERSION /usr/local; \
  rm -rf ruby-build; \
  # rough smoke test
  ruby --version; \
  gem --version;

# don't create ".bundle" in apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH

# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME"

# cleanup build environment
RUN apt-get purge -y git && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# sanity check for jemalloc
RUN ruby -r rbconfig -e "abort 'jemalloc not enabled' unless RbConfig::CONFIG['LIBS'].include?('jemalloc') || RbConfig::CONFIG['MAINLIBS'].include?('jemalloc')"

CMD ["irb"]
