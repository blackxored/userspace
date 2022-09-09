#!/bin/bash

# SSH Passthrough Setup
eval $(which ssh-agent)
export TTY=$(tty)

# Create tmxu session directory
tmuxDir=$HOME/.tmux/resurrect
mkdir -p $tmuxDir

# Userspace Command
docker run -it --rm \
  --privileged \
  -v $HOME/Documents:/Documents:rw \
  -w $HOME \
  -v $PWD:/cwd:rw \
  -v $HOME/.config:/config:rw \
  -v $tmuxDir:/home/xored/.tmux/resurrect:rw \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /run/user/$(id -u)/:/run/user/$(id -u)/:ro \
  -v $SSH_AUTH_SOCK:$SSH_AUTH_SOCK \
  -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
  -u `id -u` \
  --network host \
  ghcr.io/xoredg/userspace:main "$@"
