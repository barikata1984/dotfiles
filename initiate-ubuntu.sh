#!/bin/env bash

# Ensure that the remaining parts are executed on the home directory
cd ~
mkdir -p ~/workspace

# Install pre-requisites ===============================
sudo apt install curl

# Register repositories ================================
# Get general info of the machine - - - - -- - - - - - -
keyring_arch=$(dpkg --print-architecture)
# Brave - - - - - - - - - - - - - - - - - - - - - - - - 
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [arch=$keyring_arch signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# Wezterm - - - - - - - - - - - - - - - - - - - - - - - 
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo "deb [arch=$keyring_arch signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
# Cuda - - - - - - - - - - - - - - - - - - - - - - - - -
echo -e "Please open the following URL in your web browser:\n  https://developer.download.nvidia.com/compute/cuda/repos/"
if [ -n "$ZSH_VERSION" ]; then
  read ubuntu_version"?Then, enter your Ubuntu version (e.g., ubuntu2204)? > "
else
  read -p "Then, enter your Ubuntu version (e.g., ubuntu2204) > " ubuntu_version
fi

cuda_keyring_arch=$(uname -m)
cuda_base_url="https://developer.download.nvidia.com/compute/cuda/repos/$ubuntu_version/$cuda_keyring_arch/"
latest_cuda_keyring=$(curl -s "$cuda_base_url" | grep 'cuda-keyring.*deb' | sort -rV | head -1 | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
echo "  The latest keyring found: $latest_cuda_keyring"
cuda_keyring_url="$cuda_base_url$latest_cuda_keyring"
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
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Nvidia driver and FiraCode
kernel_version=$(echo "$(uname -r)" | tr "[:upper:]" "[:lower:]")
# Set the variable based on the condition result
if [[ ! "$kernel_version" == *"microsoft"* ]] && [[ ! "$kernel_version" == *"wsl"* ]]; then
  not_on_microsoft_wsl="true"
else
  not_on_microsoft_wsl="false"
fi

if $not_on_microsoft_wsl; then
    # FiraCode; should be isntalled on the host on WSL2
    git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts ~/workspace/nerd-fonts
    cd ~/workspace/nerd-fonts
    git config core.sparsecheckout true
    git sparse-checkout add patched-fonts/FiraCode
    bash install.sh FiraCode
    cd ~
    # Nividia Driver; should be isntalled on the host on WSL2
    # NOTE: Should not be installed on WSL not to break the link to the passed through driver on the host
    sudo ubuntu-drivers install

# Configure ============================================
# Git global config - - - - - - - - - - - - - - - - - - 
read -p "Input your git glogal user.name: " git_username
read -p "Input your git glogal user.email: " git_useremail
git config --global user.name $git_username
git config --global user.email $git_useremail
# Initiate miniconda - - - - - - - - - - - - - - - - - -
"$HOME/miniconda3/bin/conda" init bash
"$HOME/miniconda3/bin/conda" init zsh
# Symbolic-link the dotfiles - - - - - - - - - - - - - -
mkdir -p "$HOME/.config"
ln -s "$HOME/workspace/dotfiles/nvim" "$HOME/.config/nvim"
ln -s "$HOME/workspace/dotfiles/wezterm/" "$HOME/.config/wezterm.lua"
ln -s "$HOME/workspace/dotfiles/.condarc" "$HOME/.condarc"

chmod 744 "$HOME/workspace/dotfiles/initiate.zsh"
zsh "$HOME/workspace/dotfiles/initiate.zsh"
chsh -s $(which zsh)
