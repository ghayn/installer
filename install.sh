#!/bin/zsh
set -eu

source ./utils.sh

os_version=$(sw_vers -productVersion)
os_major_version=$(echo $os_version | awk -F'.' '{print $1}')
password=""

__check_requirements() {
  if [ $os_major_version -lt 12 ]; then
    echo "Current macOS version is $os_version which is not supported."
    exit 1
  fi
}

__gather_password() {
  echo 'We need admin permission to install packages.'
  password=$(password_input "Password: ")
  echo
}


start() {
  __check_requirements

  local COLUMNS=$(tput cols)  # 获取终端列数

  local separator="*"
  local message="ATTENTION: WE ARE SETTING UP DEV ENVIRONMENT"
  local arch=$(uname -m)
  local machine_model=$(sysctl -n hw.model)
  local machine_sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
  local hostname=$(hostname)

  printf "%-${COLUMNS}s\n" | tr ' ' "$separator"

  # 打印信息和左右边框
  echo
  printf "HostName: $hostname\n"
  echo
  printf "macOS Version: $os_version($arch)\n"
  echo
  printf "Machine Info: $machine_model($machine_sn)\n"
  echo

  # 打印底部边框
  printf "%-${COLUMNS}s\n" | tr ' ' "$separator"

  echo "\n!!! $message"
  __gather_password
  echo "!!! This setup will begin in 5 seconds, press Ctrl+C to cancel..."
  sleep 5
  clear
  echo "[$(date)] Time's up! Here we go!"
  echo
}

install_xcode_cli_tools() {
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
    autoinput /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" \
      {\[P\|p\]assword:} \
      $password
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
  echo "Run setup.sh at $(pwd)"
  chmod +x setup.sh && zsh -c "PASSWORD=$password ./setup.sh"
}

cleanup() {
  rm -rf /tmp/installer
}

start
install_xcode_cli_tools
install_homebrew
run_setup
cleanup
