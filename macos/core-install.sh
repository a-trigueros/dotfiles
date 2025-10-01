#! /bin/sh

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Remove Message of the day prompt
touch $HOME/.hushlogin

# Show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles YES

# Biometrics as sudo
PAM_FILE="/etc/pam.d/sudo"
TOUCHID_LINE="auth       sufficient     pam_tid.so"
if ! grep -Fxq "$TOUCHID_LINE" "$PAM_FILE"; then
  sudo cp "$PAM_FILE" "$PAM_FILE.backup" # backup
  sudo sed -i '' "1s;^;$TOUCHID_LINE\n;" "$PAM_FILE"
fi

# Fix for when connected to displaylink devices
defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
