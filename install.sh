#!/bin/zsh
set -e

macOS_version=$(sw_vers -productVersion | awk -F'.' '{print $1}')
if [ $macOS_version -gt 12 ]; then
    echo "Your macOS version is greater than 12."
else
    echo "Your macOS version is not greater than 12."
    exit 1
fi

install_xcode() {
  echo "Checking Command Line Tools for Xcode"
  # Only run if the tools are not installed yet
  # To check that try to print the SDK path
  set +e
  xcode-select -p &> /dev/null
  res=$?
  set -e

  if [ $res -ne 0 ]; then
    echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
  # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose;
  else
    echo "Command Line Tools for Xcode have been installed."
  fi
}

install_homebrew() {
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo
  echo "Install Homebrew"
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo

  if command -v brew >/dev/null 2>&1; then
      echo "Homebrew is installed. Skipping..."
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
}

run_setup() {
  tmp_dir="/tmp/installer"
  echo "Clone installer into $tmp_dir"

  if [ -d "$tmp_dir" ]; then
    cleanup
  fi

  git clone https://github.com/ghayn/installer.git /tmp/installer
  cd $tmp_dir
  echo "run setup.sh at $(pwd)"
  chmod +x setup.sh && zsh -c "./setup.sh"
}

cleanup() {
  rm -rf /tmp/installer
}

install_xcode
install_homebrew
run_setup
cleanup
