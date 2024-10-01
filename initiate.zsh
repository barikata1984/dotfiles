#!/usr/bin/env zsh

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
mv "$HOME/.zshrc" "$HOME/.miniconda-enabled-original-oh-my-zshrc"
ln -s "$HOME/workspace/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
ln -s "$HOME/workspace/dotfiles/.zprofile" "$HOME/.zprofile"
ln -s "$HOME/workspace/dotfiles/.zshrc" "$HOME/.zshrc"
