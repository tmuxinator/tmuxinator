#  vim: ft=dockerfile ai ts=2 sw=2 sts=2
FROM centos:latest
RUN \
yum update -y && \
yum install -y git-core curl gcc make build-essential openssl-devel \
readline-devel zlib-devel libssl-dev libreadline-dev libyaml-dev bzip2 gem tmux
ADD . /opt/tmuxinator
ADD ./bin/install_rbenv_version.sh /init.sh
RUN ./init.sh "2.3.6"
RUN /bin/bash -c "source /.bashrc"
ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /opt/tmuxinator/
