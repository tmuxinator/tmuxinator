#!/usr/bin/env sh
RUBY_V=$1

if [ ! -d ~/.rbenv ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
fi
if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
fi

export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init -)"

if [ ! -e .rbenv/versions/${RUBY_V} ]; then
  echo "Using rbenv"
  rbenv install -v ${RUBY_V}
fi

cd /opt/tmuxinator

if [ ! -e /home/vagrant/.rbenv/shims/bundle ]; then
  gem install bundler --version '<= 1.9.9'
  rbenv rehash
fi

bundle install

rake spec
