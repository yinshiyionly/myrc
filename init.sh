#!/usr/bin/env bash

# Init soft links

MYRC_INSTALL_DIR="/home/eleven/.myrc"

# Install zsh
`sudo apt install zsh`

# Init oh-my-zsh
`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/zshrc ${USER}/.zshrc`

`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/ohmyzsh ${USER}/.oh-my-zsh`

# Init p10k.zsh
`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/p10k.zsh ${USER}/.p10k.zsh`

# Init powerlevel10k
`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/themes/powerlevel10k ${USER}/.powerlevel10k`

# Init alias
`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/alias ${USER}/.alias`

# Init function
`ln -s ${MYRC_INSTALL_DIR}/oh-my-zsh/function ${USER}/.function`
