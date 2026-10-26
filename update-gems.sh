#!/bin/bash

if [ "$RUBY_VERSION" = "2.6.10" ]; then
  gem update --system
fi

if [ "$RUBY_VERSION" = "2.7.8" ]; then
  gem update --system
fi
