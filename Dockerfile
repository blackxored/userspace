FROM alpine:latest
LABEL maintainer "Adrian Perez <adrian@adrianperez.org>"
LABEL org.opencontainers.image.source https://github.com/xoredg/userspace

ARG user=xored
ARG group=wheel
ARG uid=1000
ARG dotfiles=dotfiles.git
ARG userspace=userspace.git
ARG vcsprovider=github.com
ARG vcsowner=xoredg

USER root

RUN \
 echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.9/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.9/community" >> /etc/apk/repositories \
    && apk upgrade --no-cache \
    && apk add --update --no-cache \
        sudo \
        autoconf \
        automake \
        libtool \
        nasm \
        ncurses \
        ca-certificates \
        libressl \
        git git-doc \
        python3 \
        python3-dev \
        py3-pip \
        openssh \
        openssl \
        bash-completion \
        cmake \
        ctags \
        file \
        curl \
        build-base \
        gcc \
        coreutils \
        wget \
        npm \
        neovim \
        zsh \
        docker \
        docker-compose \
        direnv \
        jq \
        tmux \
        ripgrep \
        yaml-cpp=0.6.2-r2 \
        fontconfig \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools \
    && npm install -g yarn

# User configuration
RUN \
  echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  adduser -D -G ${group} ${user} && \
  addgroup ${user} docker

COPY ./ /home/${user}/.userspace/
RUN chown -R ${user}:${group} /home/${user}/.userspace/

RUN \
   git clone --recursive https://${vcsprovider}/${vcsowner}/${dotfiles} /home/${user}/.dotfiles && \
   chown -R ${user}:${group} /home/${user}/.dotfiles && \
   cd /home/${user}/.dotfiles && \
   sudo -u ${user} git remote set-url origin git@${vcsprovider}:${vcsowner}/${dotfiles} && \
   chown -R ${user}:${group} /home/${user}/.userspace && \
   cd /home/${user}/.userspace && \
   sudo -u ${user} git remote set-url origin git@${vcsprovider}:${vcsowner}/${userspace} 

 USER ${user}
RUN \
  cd $HOME/.dotfiles && \
  ./install-profile linux \
  && cd $HOME/.userspace \
  && if [ ! -d ~/.fzf ]; then git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; fi && ~/.fzf/install --key-bindings --completion --no-update-rc \
  && ./install-standalone \
    zsh-dependencies \
    zsh-plugins \
    nvim-dependencies

ENV HISTFILE=/config/.history
CMD []
