#!/bin/bash

# Log all output to setup.log
exec > >(tee -a setup.log) 2>&1

# Personalization variables
USER_NAME="Your Name"                  # Replace with your name
USER_EMAIL="your.email@example.com"    # Replace with your email
GITHUB_USERNAME="your_github_username" # Replace with your GitHub username

# Global array to store installed GUI apps
INSTALLED_GUI_APPS=()

# Function to install Homebrew
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "Enabling Homebrew..."
  SHELL_PROFILE=""
  case $SHELL in
    */bash) SHELL_PROFILE=~/.bash_profile ;;
    */zsh) SHELL_PROFILE=~/.zshrc ;;
    *) SHELL_PROFILE=~/.profile ;;
  esac
  (
    echo
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  ) >> "$SHELL_PROFILE"
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Function to install CLI tools
install_cli_tools() {
  echo "Installing CLI tools..."
  local tools=(
    "dockutil dockutil"
    "gh gh"
    "git git"
    "python python"
  )

  for tool in "${tools[@]}"; do
    IFS=' ' read -r pkg_name tool_name <<< "$tool"
    brew install "$pkg_name" || { FAILED_CLI+=("$tool_name"); }
  done

  pip3 install notebook || { FAILED_CLI+=("Jupyter Notebook"); }

  if [ ${#FAILED_CLI[@]} -gt 0 ]; then
    return 1
  fi
}

# Function to install GUI applications
install_gui_apps() {
  echo "Installing GUI applications..."

  # Fetch the GUI apps list from the URL
  GUI_APPS_URL="https://raw.githubusercontent.com/seneren/automated-setup-for-Mac/main/gui_apps.txt"
  GUI_APPS_FILE=$(mktemp)
  if ! curl -fsSL "$GUI_APPS_URL" -o "$GUI_APPS_FILE"; then
    echo "Error: Failed to fetch GUI apps list. Skipping GUI app installation."
    rm -f "$GUI_APPS_FILE"
    return 1
  fi

  # Read the GUI apps list
  while IFS=' ' read -r cask_name app_name; do
    if brew install --cask "$cask_name"; then
      INSTALLED_GUI_APPS+=("$app_name")
    else
      FAILED_GUI+=("$app_name")
    fi
  done < "$GUI_APPS_FILE"

  # Clean up the temporary file
  rm -f "$GUI_APPS_FILE"

  if [ ${#FAILED_GUI[@]} -gt 0 ]; then
    return 1
  fi
}

# Function to configure the Dock
configure_dock() {
  echo "Setting up dock..."

  # Remove all existing apps from the Dock
  dockutil --remove all --no-restart

  # Add pre-installed apps (these are always available on macOS)
  dockutil --add "/System/Applications/Finder.app" --no-restart
  dockutil --add "/System/Applications/Launchpad.app" --no-restart
  dockutil --add "/Applications/Safari.app" --no-restart
  dockutil --add "/System/Applications/Mail.app" --no-restart
  dockutil --add "/System/Applications/Notes.app" --no-restart
  dockutil --add "/System/Applications/Utilities/Terminal.app" --no-restart

  # Add installed GUI apps to the Dock (using app_name from install_gui_apps)
  for app_name in "${INSTALLED_GUI_APPS[@]}"; do
    app_path="/Applications/${app_name}.app"
    if [[ -e "$app_path" ]]; then
      dockutil --add "$app_path" --no-restart
    fi
  done

  # Add spacer, Applications, Downloads, and Trash
  dockutil --add '' --type spacer --section apps --no-restart
  dockutil --add '/Applications' --view grid --display folder --no-restart
  dockutil --add '~/Downloads' --view list --display folder --no-restart
  dockutil --add '~/.Trash' --view grid --display folder

  echo "Dock setup complete."
}

# Function to configure Git and SSH
configure_git() {
  echo "Setting up Git..."
  git config --global user.name "$USER_NAME"
  git config --global user.email "$USER_EMAIL"
  git config --global core.editor "code --wait"
  git config --global push.default upstream

  echo "Generating SSH keys..."
  mkdir -p ~/.ssh
  if ! ssh-keygen -t ed25519 -C "$USER_EMAIL" -f ~/.ssh/id_ed25519 -N ""; then
    echo "SSH key generation failed. Skipping Git and SSH setup."
    FAILED_GIT+=("SSH key generation")
    return 1
  fi
  chmod 600 ~/.ssh/id_ed25519
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  echo "SSH key generated. Add the following public key to your GitHub account:"
  cat ~/.ssh/id_ed25519.pub

  # Pause to allow copying the SSH key
  read -p "Please press Enter to open Safari and continue to setup..."

  # Open Safari to GitHub SSH keys page
  echo "Opening Safari to GitHub SSH keys page..."
  echo "Safari has been opened to the GitHub SSH keys page. Please add the SSH key."
  open -a Safari "https://github.com/settings/ssh/new"

  # Optional: Set up PAT for HTTPS Git operations
  read -p "Do you want to set up a GitHub PAT for HTTPS Git operations? (y/n): " SETUP_PAT
  if [[ "$SETUP_PAT" == "y" ]]; then
    echo "Please create a GitHub PAT here: https://github.com/settings/tokens"
    read -s -p "Enter your GitHub PAT: " GITHUB_PAT
    echo
    git config --global credential.helper "osxkeychain"
    echo "https://$GITHUB_USERNAME:$GITHUB_PAT@github.com" | git credential-osxkeychain store
    echo "GitHub PAT configured securely using macOS keychain."
  fi
}

# Function to configure macOS settings
configure_macos_settings() {
  echo "Updating macOS settings..."
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
  defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.dock show-recents -bool FALSE
  defaults write com.apple.Dock showhidden -bool TRUE
  killall Dock
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write com.apple.finder FXPreferredViewStyle Clmv
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  killall Finder
  defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist DADisableEjectNotification -bool YES
  killall diskarbitrationd
}

# Arrays to track failed installations
FAILED_CLI=()
FAILED_GUI=()
FAILED_GIT=()
FAILED_MACOS=()

# Run each module and log failures
install_homebrew || FAILED_MACOS+=("Homebrew")
install_cli_tools || FAILED_CLI=("${FAILED_CLI[@]}")
install_gui_apps || FAILED_GUI=("${FAILED_GUI[@]}")
configure_dock
configure_git || FAILED_GIT=("${FAILED_GIT[@]}")
configure_macos_settings || FAILED_MACOS+=("macOS Settings")

# Report failed installations at the end
if [ ${#FAILED_CLI[@]} -gt 0 ] || [ ${#FAILED_GUI[@]} -gt 0 ] || [ ${#FAILED_GIT[@]} -gt 0 ] || [ ${#FAILED_MACOS[@]} -gt 0 ]; then
  echo "Setup completed with errors. Please install the following manually to complete the setup:"
  
  if [ ${#FAILED_CLI[@]} -gt 0 ]; then
    echo "- CLI Tools: ${FAILED_CLI[*]}"
  fi
  if [ ${#FAILED_GUI[@]} -gt 0 ]; then
    echo "- GUI Applications: ${FAILED_GUI[*]}"
  fi
  if [ ${#FAILED_GIT[@]} -gt 0 ]; then
    echo "- Git and SSH Configuration: ${FAILED_GIT[*]}"
  fi
  if [ ${#FAILED_MACOS[@]} -gt 0 ]; then
    echo "- macOS Settings: ${FAILED_MACOS[*]}"
  fi
else
  echo "Setup complete!"
fi

# Open the folder containing setup.log and select the file
open -R setup.log