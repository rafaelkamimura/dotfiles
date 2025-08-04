# Dotfiles

My personal dotfiles configuration for macOS.

## Contents

- **Shell**: Zsh with Powerlevel10k theme
  - `.zshrc` - Zsh configuration
  - `.zprofile` - Zsh profile
  - `.p10k.zsh` - Powerlevel10k configuration

- **Terminal**: tmux configuration
  - `.tmux.conf` - tmux settings

- **Window Management**: 
  - `.skhdrc` - skhd hotkey daemon configuration
  - `.config/yabai/` - yabai window manager configuration

- **Status Bar**:
  - `.config/sketchybar/` - sketchybar configuration

- **Shell**: 
  - `.config/fish/` - fish shell configuration

- **Git**: 
  - `.gitconfig` - Git configuration

## Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/github/dotfiles
```

2. Create symbolic links:
```bash
ln -s ~/github/dotfiles/.zshrc ~/.zshrc
ln -s ~/github/dotfiles/.zprofile ~/.zprofile
ln -s ~/github/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -s ~/github/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/github/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/github/dotfiles/.skhdrc ~/.skhdrc

# For config directories
ln -s ~/github/dotfiles/.config/sketchybar ~/.config/sketchybar
ln -s ~/github/dotfiles/.config/yabai ~/.config/yabai
ln -s ~/github/dotfiles/.config/fish ~/.config/fish
```

## Dependencies

- [Homebrew](https://brew.sh/)
- [yabai](https://github.com/koekeishiya/yabai) - Tiling window manager
- [skhd](https://github.com/koekeishiya/skhd) - Hotkey daemon
- [sketchybar](https://github.com/FelixKratz/SketchyBar) - Status bar
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme