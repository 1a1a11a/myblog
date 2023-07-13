
# https://github.com/andreondra/jekyll-theme-simplex

# needed when installing on a ubuntu node with no ruby installed
# sudo apt update
# sudo apt install -yqq ruby-bundler ruby-dev build-essential 
# git config --global user.email peter.waynechina@gmail.com
# git config --global user.name Jason


bundle install
bundle exec jekyll serve --watch --host 0.0.0.0 --safe

jekyll serve --livereload

