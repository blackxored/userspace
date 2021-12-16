FROM alpine:latest
LABEL maintainer "Adrian Perez <adrian@adrianperez.org>"
LABEL org.opencontainers.image.source https://github.com/blackxored/userspace

ARG user=xored
ARG group=wheel
ARG uid=1000
ARG dotfiles=dotfiles.git
ARG userspace=userspace.git
ARG vcsprovider=github.com
ARG vcsowner=xoredg

USER root

RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    apk add --update --no-cache \
        sudo \
        autoconf \
        automake \
        libtool \
        nasm \
        ncurses \
        ca-certificates \
        libressl \
        bash-completion \
        cmake \
        ctags \
        file \
        curl \
        build-base \
        gcc \
        coreutils \
        wget \
        neovim \
        git git-doc \
        zsh \
        docker \
        docker-compose

# User configuration
RUN \
  echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  adduser -D -G ${group} ${user} && \
  addgroup ${user} docker

COPY ./ /home/${user}/.userspace/

RUN \
   git clone --recursive git@${vcsprovider}:${vcsowner}/${dotfiles} /home/${user}/.dotfiles && \
   chown -R ${user}:${group} /home/${user}/.dotfiles && \
   chown -R ${user}:${group} /home/${user}/.userspace && \
   cd /home/${user}/.userspace && \
   git remote set-url origin git@${vcsprovider}:${vcsowner}/${userspace} && \
   cd /home/${user}/.dotfiles && \
   git remote set-url origin git@${vcsprovider}:${vcsowner}/${dotfiles}

USER ${user}
RUN \
  cd $HOME/.dotfiles && \
  ./install-profile default && \
  ./install-standalone \
    zsh-dependencies \
    zsh-plugins \
    vim-dependencies \
    vim-plugins \
    tmux-plugins

ENV HISTFILE=/config/.history
CMD []
