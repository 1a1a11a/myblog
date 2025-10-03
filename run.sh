#!/bin/bash
# https://github.com/andreondra/jekyll-theme-simplex

# needed when installing on a ubuntu node with no ruby installed
# sudo apt update
# sudo apt install -yqq ruby-bundler ruby-dev build-essential 
# git config --global user.email peter.waynechina@gmail.com
# git config --global user.name Jason

# sudo apt install libvips

# For macOS with Homebrew Ruby (ARM64)
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

bundle install
bundle exec jekyll serve --watch --host 0.0.0.0

