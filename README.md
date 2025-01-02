# Automated Setup for Mac

This repository contains a **Bash script** to automate the setup of a macOS development environment. The script installs essential tools, applications, and configurations, making it easy to set up a new Mac quickly and consistently.

## Features

- **Homebrew Installation**: Installs Homebrew (if not already installed) and sets it up.
- **CLI Tools**: Installs essential command-line tools like `git`, `gh`, `python`, and `dockutil`.
- **GUI Applications**: Installs popular GUI applications (e.g., Brave Browser, Visual Studio Code, Spotify) using a customizable list.
- **Dock Configuration**: Customizes the macOS Dock with pre-installed and successfully installed apps.
- **Git and SSH Setup**: Configures Git and generates an SSH key for GitHub.
- **macOS Settings**: Updates macOS settings for a better user experience (e.g., disabling `.DS_Store` creation, enabling three-finger drag).
- **Error Handling**: Logs failures and provides a summary of what needs to be installed manually.

- ## Prerequisites

- **macOS**: The script is designed for macOS.
- **Internet Connection**: Required to download and install packages.
- **GitHub Account**: Needed for Git and SSH setup.

- ## Usage

### 1. Run the Script
To execute the script, open **Terminal** and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/seneren/automated-setup-for-Mac/main/setup.sh)"
```

### 2. Follow the Prompts
The script will guide you through the setup process, including:
- Installing Homebrew.
- Installing CLI tools and GUI applications.
- Configuring Git and generating an SSH key.
- Updating macOS settings.

### 3. Review the Log
All output is logged to `setup.log` in the current directory. After the script finishes, the log file will open automatically for review.

## Personalization

Before running the script, update the following variables at the **top of the script**:

```bash
USER_NAME="Your Name"                  # Replace with your name
USER_EMAIL="your.email@example.com"    # Replace with your email
GITHUB_USERNAME="your_github_username" # Replace with your GitHub username
```

These variables are used for:
- Git configuration.
- SSH key generation.
- GitHub PAT setup (if enabled).

- ## Customization

### GUI Applications
The list of GUI applications to install is defined in the [`gui_apps.txt`](https://raw.githubusercontent.com/seneren/automated-setup-for-Mac/main/gui_apps.txt) file. You can customize this list by editing the file in the repository.

#### Example `gui_apps.txt`:
```
brave-browser Brave Browser
discord Discord
visual-studio-code Visual Studio Code
spotify Spotify
whatsapp WhatsApp
```

### macOS Settings
The script applies a set of predefined macOS settings. If you want to customize these settings, you can modify the `configure_macos_settings` function in the script.

## Troubleshooting

### 1. Failed Installations
If some installations fail, the script will display a summary of what needs to be installed manually. For example:
```
Setup completed with errors. Please install the following manually to complete the setup:
- CLI Tools: python
- GUI Applications: Discord
```

### 2. Log File
All output is logged to `setup.log`. Review this file for detailed information about what went wrong.

### 3. Fetching `gui_apps.txt`
If the script fails to fetch the `gui_apps.txt` file, it will skip the GUI app installation step. Ensure the file is accessible at:
```
https://raw.githubusercontent.com/seneren/automated-setup-for-Mac/main/gui_apps.txt
```

## Repository Structure

```
automated-setup-for-Mac/
├── setup.sh              # Main setup script
├── gui_apps.txt          # List of GUI applications to install
├── README.md             # This file
└── setup.log             # Log file generated during script execution
```

## Contributing

If you’d like to contribute to this project, feel free to open an issue or submit a pull request. Contributions are welcome!

# This script is based on the original work by Mark R. Florkowski from https://github.com/markflorkowski.
# Modifications have been made to the original script to include additional configurations and adjustments.

## Download README.md

To download this `README.md` file, click the link below:

[Download README.md](https://raw.githubusercontent.com/seneren/automated-setup-for-Mac/main/README.md)

### How to Download
1. Click the **Download README.md** link above.
2. The file will open in your browser.
3. Right-click anywhere on the page and select **Save As** (or use `Ctrl+S` / `Cmd+S`) to save the file to your computer.
