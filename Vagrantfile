# frozen_string_literal: true
# -- vim: ft=ruby ai tabstop=4 softtabstop=0 expandtab shiftwidth=2 smarttab
VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.9.1"

RUBY_V = "2.3.6"

$apt_setup = <<~SCRIPT
  sudo apt update
  sudo apt install -y git-core curl build-essential libreadline-dev libyaml-dev tmux gem
SCRIPT

$yum_setup = <<~SCRIPT
  sudo yum update
  sudo yum install -y git-core curl  openssl-devel readline-devel zlib-devel build-essential libssl-dev libreadline-dev libyaml-dev gem tmux
SCRIPT

$rbenv_script = <<~SCRIPT
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
  if [ ! -e .rbenv/versions/#{RUBY_V} ]; then
    echo "Using rbenv"
    rbenv install -v #{RUBY_V}
  fi

  cd /opt/tmuxinator

  if [ ! -e /home/vagrant/.rbenv/shims/bundle ]; then
    gem install bundler --version '<= 1.9.9'
    rbenv rehash
  fi

  bundle install
SCRIPT

distros = {
  debian: {
    ubuntu_16_04: "bento/ubuntu-16.04"
  },
  redhat: {
    centos_7: "centos/7"
  }
  # "jhcook/macos-sierra" for mac osx
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Sync build folder
  config.vm.synced_folder ".", "/opt/tmuxinator"

  distros.each do |distro, versions|
    versions.each  do |name, box|
      config.vm.define name.to_s.tr("/", "_") do |b|
        b.vm.box = box.to_s

        if distro == :redhat
          b.vm.provision :shell, privileged: false, inline: $yum_setup
        end

        if distro == :debian
          b.vm.provision :shell, privileged: false, inline: $apt_setup
        end

        b.vm.provision :shell, privileged: false, inline: $rbenv_script
      end
    end
  end
end
