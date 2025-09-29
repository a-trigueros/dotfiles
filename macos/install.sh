#! /bin/sh

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Remove Message of the day prompt
touch $HOME/.hushlogin

# Show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles YES

# Install tcr
sudo mkdir -p /opt/tcr
curl -s -L https://github.com/murex/TCR/releases/download/v1.4.1/tcr_1.4.1_Darwin_arm64.tar.gz | sudo tar -xvz - -C /opt/tcr
echo 'PATH=$PATH:/opt/tcr' >>~/.zshr
