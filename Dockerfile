FROM ubuntu:focal

LABEL maintainer="Adam Radabaugh <adam@mediaping.net>"

ARG RUBY_VERSION=2.6.10
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# container dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    autoconf \
    apt-transport-https \
    bison \
    build-essential \
    ca-certificates \
    curl \
    git \
    libdb-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm6 \
    libjemalloc-dev \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    tzdata \
    wget \
    zlib1g-dev && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

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
ENV GEM_HOME=/gems
ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_APP_CONFIG="${GEM_HOME}"
ENV PATH="${GEM_HOME}/bin:${PATH}"

# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME"

# Update ruby gem command and default gems if Ruby > 2.6
ADD update-gems.sh update-gems.sh
RUN ./update-gems.sh

# sanity check for jemalloc
RUN ruby -r rbconfig -e "abort 'jemalloc not enabled' unless RbConfig::CONFIG['LIBS'].include?('jemalloc') || RbConfig::CONFIG['MAINLIBS'].include?('jemalloc')"

CMD ["irb"]
