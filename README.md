# My Dotfiles

This is my personal dotfiles repository.

## Installation

clone this repository to your home directory

```bash
git clone https://github.com/DaLukasDev/dots.git ~/.dotfiles
```

then run the setup script

```bash
cd ~/.dotfiles
./setup.sh
```

## Usage

The dotfiles will be linked by GNU Stow. To use them, run the following command:

```bash
stow -t $HOME dotfiles
```

The setup script is a script that will install all the dotfiles and their dependencies.
Based on your operating system, it will install the necessary packages and tools.
