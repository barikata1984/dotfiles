#!/usr/bin/env bash

# Ensure that the remaining parts are executed on the home directory
cd ~
mkdir -p ~/workspace

# Install pre-requisites ===============================
sudo apt install curl

# Registrater repositories =============================
# Get general info of the machine - - - - -- - - - - - -
keyring_arch=$(dpkg --print-architecture)
# Brave - - - - - - - - - - - - - - - - - - - - - - - - 
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [arch=$keyring_arch signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# Wezterm - - - - - - - - - - - - - - - - - - - - - - - 
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo "deb [arch=$keyring_arch signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
# Cuda - - - - - - - - - - - - - - - - - - - - - - - - -
echo -e "Please open the following URL in your web browser:\n    https://developer.download.nvidia.com/compute/cuda/repos/"
read -p "Then, enter your Ubuntu version (e.g., ubuntu2204): " ubuntu_version
cuda_keyring_arch=$(uname -m)
echo "cuda_keyring_arch: $cuda_keyring_arch"
cuda_base_url="https://developer.download.nvidia.com/compute/cuda/repos/$ubuntu_version/$cuda_keyring_arch"
latest_cuda_keyring=$(curl -s "$cuda_base_url" | grep 'cuda-keyring.*deb' | sort -rV | head -1 | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
echo "latest_cuda_keyring: $latest_cuda_keyring"
cuda_keyring_url="$cuda_base_url$latest_cuda_keyring"
echo "cuda_keyring_url: $cuda_keyring_url"
wget $cuda_keyring_url
sudo dpkg -i $latest_cuda_keyring
rm $latest_cuda_keyring

# Install apps =========================================
sudo apt update
# Brave
sudo apt install brave-browser
# Wezterm
sudo apt install wezterm
# Neovim
sudo snap install nvim --classic
# Zsh
sudo apt install zsh
# Miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
# FiraCode
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts ~/workspace/nerd-fonts
cd ~/workspace/nerd-fonts
git config core.sparsecheckout true
git sparse-checkout add patched-fonts/FiraCode
bash install.sh FiraCode
cd ~
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
source $HOME/.zshrc  # to export ZSH_CUSTOM
# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# Nvidia driver
kernel_version=$(echo "$(uname -v)" | tr '[:upper:]' '[:lower:]')
if [[ ! "$lowercase_string" == *"microsoft"* ]] && [[ ! "$lowercase_string" == *"wsl"* ]]; then
    sudo ubuntu-drivers install  # NOTE: Should not be called on WSL because it can pass through Windows
                                 #       to use the VGA.

# Configure ============================================
# Git global config - - - - - - - - - - - - - - - - - - 
read -p "Input your git glogal user.name: " git_username
read -p "Input your git glogal user.email: " git_useremail
git config --global user.name $git_username
git config --global user.email $git_useremail
# Initiate miniconda - - - - - - - - - - - - - - - - - -
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh
# Symbolic link the dotfiles - - - - - - - - - - - - - -
mv ~/.bashrc ~/.miniconda-enabled-bashrc
mv ~/.zshrc ~/.miniconda-enabled-original-oh-my-zshrc
ln -s ~/workspace/dotfiles/nvim ~/.config/nvim
ln -s ~/workspace/dotfiles/wezterm/ ~/.config/wezterm.lua
ln -s ~/workspace/dotfiles/.bashrc ~/.bashrc
ln -s ~/workspace/dotfiles/.condarc ~/.condarc
ln -s ~/workspace/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -s ~/workspace/dotfiles/.zprofile ~/.zprofile
ln -s ~/workspace/dotfiles/.zshrc ~/.zshrc

chsh -s $(which zsh)
