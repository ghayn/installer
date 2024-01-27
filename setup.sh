#!/bin/zsh
set -eu

source ./utils.sh

password=$PASSWORD

check_homebrew_is_installed_and_setup_env() {
  BREW_PATH="/usr/local/bin/brew"
  [[ $(uname -m) == "arm64" ]] && BREW_PATH="/opt/homebrew/bin/brew"

  if [ ! -f "$BREW_PATH" ]; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
  fi

  eval "$($BREW_PATH shellenv)"
}

install_packages() {
  echo "Install Homebrew through brewfile (this may take a while)"

  autoinput "brew bundle" {\[P\|p\]assword:} $password
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
  source $HOME/.zshenv
  source $HOME/.zshrc
  zimfw build
}

install_asdf_runtime() {
  asdf_runtime_plugins=("nodejs" "ruby" "python")

  for plugin in "${asdf_runtime_plugins[@]}"; do
    asdf plugin add $plugin
  done

  latest_ruby_version=$(asdf latest ruby)
  latest_python_version=$(asdf latest python)
  latest_nodejs_lts_version=$(asdf latest nodejs 20)

  asdf_runtime_versions=(
    "ruby" "$latest_ruby_version"
    "python" "$latest_python_version"
    "nodejs" "$latest_nodejs_lts_version"
  )

  asdf plugin update --all

  for runtime version in "${asdf_runtime_versions[@]}"; do
    asdf install $runtime $version
    asdf global $runtime $version
  done
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

check_homebrew_is_installed_and_setup_env
install_packages
install_zimfw
install_gpakosz_tmux
apply_dotfiles
install_asdf_runtime
install_extra_packages
cleanup
