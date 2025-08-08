#!/bin/sh

WORKING_DIR=$PWD
DOT_DIR="${WORKING_DIR}/dotfiles"
BREWS="
ffmpeg
fastfetch
neovim
git
zsh
alt-tab
wget
htop
android-platform-tools
gpg2
bitwarden
docker-compose
whatsapp
nvm
fzf
zoxide
docker
colima
delta
stow
jandedobbeleer/oh-my-posh/oh-my-posh
"

CASKS="
rectangle
wezterm
quicklook-json
qlprettypatch
quicklook-csv
betterzip
webp-quicklook
suspicious-package
gpg-suite-no-mail
google-chrome
firefox@developer-edition
visual-studio-code
discord
"

### Detect OS
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
    PLATFORM="macos"
    xcode-select --install

    echo "Checking for brew"
    echo '---------------------'
    if ! command -v brew > /dev/null; then
        echo "\xF0\x9F\x8D\xBA Homebrew Not found installing now"
        rm -rf /usr/local/Cellar /usr/local/.git && brew cleanup
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "\xF0\x9F\x8D\xBA Homebrew found updating now"
        brew update
    fi
elif [ "$OS" = "Linux" ]; then
    PLATFORM="linux"
else
    echo "❌ Unsupported platform: $OS"
    exit 1
fi

# Detect package manager
if command -v apt > /dev/null; then
    PKG_MANAGER="apt"
elif command -v pacman > /dev/null; then
    PKG_MANAGER="pacman"
elif command -v brew > /dev/null; then
    PKG_MANAGER="brew"
elif command -v apk > /dev/null; then
    PKG_MANAGER="apk"
else
    echo "❌ Unsupported package manager."
    exit 1
fi

INSTALL_PROFILE="minimal"  # default
for arg in "$@"; do
    case $arg in
        --full)
            INSTALL_PROFILE="full"
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--full]"
            exit 1
            ;;
    esac
done

# Ask for the administrator password upfront
sudo -v

touch $HOME/.hushlogin

clear
echo "DaLukas Install script started."

cd ~

echo "Detected package manager: $PKG_MANAGER"

echo "Installing base packages"

if [ "$PKG_MANAGER" = "apt" ]; then

    export DEBIAN_FRONTEND=noninteractive
    sudo apt update
    sudo apt install -y zsh git ca-certificates curl wget gpg apt-transport-https fzf zoxide stow
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    . /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif [ "$ID" = "debian" ]; then
        echo "Running on Debian"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker
    sudo usermod -aG docker $USER
    curl -s https://ohmyposh.dev/install.sh | bash -s

    if [ "$INSTALL_PROFILE" = "full" ]; then
        curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
        sudo apt-get install wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
        rm -f microsoft.gpg
        sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

        sudo apt update
        sudo apt install -y google-chrome-stable code
    fi

elif [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -Sy --noconfirm --needed base-devel zsh git docker docker-compose fzf zoxide
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ~

    if [ "$INSTALL_PROFILE" = "full" ]; then
        sudo pacman -S --noconfirm gnome-themes-extra noto-fonts noto-fonts-extra noto-fonts-emoji ttf-fira-code stow
        paru -S --noconfirm google-chrome visual-studio-code-bin spotify firefox-developer-edition
    fi
elif [ "$PKG_MANAGER" = "brew" ]; then
    for b in $BREWS; do
       echo "Installing $b"
       brew install $b
    done
    for c in $CASKS; do
      echo "Installing $c"
      brew install --cask $c
    done
    echo "Setting mac defaults right now"
    echo '---------------------'
    sh $WORKING_DIR/macos/set-defaults.sh
elif [ "$PKG_MANAGER" = "apk" ]; then
    apk add --no-cache bash zsh git docker docker-compose doas shadow curl fzf zoxide stow
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi

cd ~

if [ $0 != "/bin/zsh" ]; then 
    echo "Switching default shell to Zsh!"
    if [ "$PKG_MANAGER" = "apk" ]; then
        chsh -s /bin/zsh
    else
        chsh -s /usr/bin/zsh
    fi
else
    echo "Zsh is the default shell already!"
fi

cd $WORKING_DIR 
echo "Installing dotfiles"
stow -t "$HOME" dotfiles -v
echo "installed dotfiles"
