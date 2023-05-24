#!/bin/zsh
set -eu

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

install_packages() {
  echo "Install Homebrew through brewfile"

  brew bundle
}

install_zimfw() {
  echo "Install Homebrew through brewfile"

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
  zimfw build
}

install_asdf_runtime() {

  latest_ruby_version=$(asdf latest ruby)
  latest_python_version=$(asdf latest python)
  asdf_runtime_plugins=("nodejs" "ruby" "python")
  asdf_runtime_versions=(
    "nodejs" "lts"
    "ruby" "$latest_ruby_version"
    "python" "$latest_python_version"
  )

  for plugin in "${asdf_runtime_plugins[@]}"; do
    asdf plugin add $plugin
  done

  asdf plugin update --all

  for runtime version in "${asdf_runtime_versions[@]}"; do
    asdf install $runtime $version
  done

  asdf global nodejs lts
  asdf global ruby $latest_ruby_version
  asdf global python $latest_python_version
}

install_extra_packages() {
  npm install -g npm

  npm install -g pnpm

  gem update --system

  pip install --upgrade pip

  curl -sSL https://install.python-poetry.org | python

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
}

cleanup() {
  brew cleanup
}

start
install_packages
install_zimfw
install_gpakosz_tmux
apply_dotfiles
install_asdf_runtime
install_extra_packages
cleanup
