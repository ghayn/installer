#!/bin/zsh
set -e

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "No macOS detected!"
  exit 1
fi

start() {
  printf '=%.0s' {1..$(($COLUMNS-1))}; echo
  echo " !! ATTENTION !! "
  echo " YOU ARE SETTING UP: Dev Environment (macOS) "
  printf '=%.0s' {1..$(($COLUMNS-1))}; echo
  echo ""
  echo -n " * The setup will begin in 5 seconds..."

  sleep 5

  echo "Times up! Here we go!"
}

install_homebrew() {
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo
  echo "Install Homebrew"
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

install_packages() {
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo
  echo "Install Homebrew through brewfile"
  printf '-%.0s' {1..$(($COLUMNS-1))}; echo

  brew bundle
}

install_zimfw() {
  cd $HOME
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
}

install_gpakosz_tmux() {
  cd $HOME
  mkdir -p ".config/tmux";
  git clone https://github.com/gpakosz/.tmux.git ".config/tmux";
  ln -s -f .config/tmux/.tmux.conf
}

apply_dotfiles() {
  cd $HOME
  chezmoi init --apply https://github.com/ghayn/dotfiles.git
}

function cleanup() {
    brew cleanup
}

__execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

__execute_sudo() {
  local -a args=("$@")
  if have_sudo_access
  then
    if [[ -n "${SUDO_ASKPASS-}" ]]
    then
      args=("-A" "${args[@]}")
    fi
    execute "/usr/bin/sudo" "${args[@]}"
  else
    execute "${args[@]}"
  fi
}


start
install_homebrew
install_packages
cleanup
