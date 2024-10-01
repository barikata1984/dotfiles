# Install apps and fonts
# WSL2 (and maybe Ubuntu22.04)
wsl --install
# PowerShell
winget install --id Microsoft.PowerShell --source winget
# Brave browser
winget install --id Brave.Brave --source winget
# Visual Studio 2022
winget install --id Microsoft.VisualStudio.2022.Community --source winget
# Neovim
winget install --id Neovim.Neovim --source winget
# Nvidia GeForce Experience
winget install --id Nvidia.GeForceExperience --source winget
# Wezterm
winget install --id wez.wezterm --source winget
# Sonos controller
winget install --id Sonos.Controller --source winget
# FiraCode
& ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Name fira-code

# Symbolic-limnk Neovim and Wezterm configurations
$configPath = "$env:HOMEPATH\.config"
# Create the .config directory if it doesn't exist
if (!(Test-Path -Path "$configPath")) {
  New-Item -ItemType Directory -Path "$configPath"
}
# Wezterm configuration
$sourcePath = "$env:HOMEPATH\workspace\dotfiles\wezterm"
$destinationPath = "$configPATH\wezterm"
New-Item -ItemType SymbolicLink -Path $destinationPath -Target $sourcePath
# Neovim configuration
$sourcePath = "$env:HOMEPATH\workspace\dotfiles\nvim"
$appDataLocalPath = "$env:HOMEPATH\AppData\Local"
$destinationPath = "$appDataLocalPath\nvim"
New-Item -ItemType SymbolicLink -Path $destinationPath -Target $sourcePath
# WSL2 configuration
New-Item -ItemType SymbolicLink -Path "$env:HOMEPATH\.wslconfig" -Value "$env:HOMEPATH\workspace\dotfiles\.wslconfig"
