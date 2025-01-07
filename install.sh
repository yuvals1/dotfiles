#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logger functions
log() {
	echo -e "${BLUE}📦 $1${NC}"
}

error() {
	echo -e "${RED}❌ $1${NC}"
}

success() {
	echo -e "${GREEN}✓ $1${NC}"
}

exists() {
	echo -e "${YELLOW}👌 $1${NC}"
}

# Check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check if any packages need to be installed
check_packages_status() {
	local need_install=false

	while read -r package || [ -n "$package" ]; do
		# Skip comments and empty lines
		[[ $package =~ ^#.*$ ]] || [ -z "$package" ] && continue

		# Check if package is installed
		if ! dpkg -l | grep -q "^ii  $package "; then
			need_install=true
			break
		fi
	done <packages.txt

	echo "$need_install"
}

# Install packages from packages.txt
install_base_packages() {
	# First check if we need to install anything
	if [ "$(check_packages_status)" = "false" ]; then
		success "All base packages are already installed"
		return 0
	fi

	log "Installing missing packages from packages.txt..."

	# Remove problematic repository to avoid apt update errors
	sudo rm -f /etc/apt/sources.list.d/nodesource.list

	# Update package list quietly
	sudo apt update 2>/dev/null

	while read -r package || [ -n "$package" ]; do
		# Skip comments and empty lines
		[[ $package =~ ^#.*$ ]] || [ -z "$package" ] && continue

		# Check if package is already installed
		if dpkg -l | grep -q "^ii  $package "; then
			exists "$package already installed"
		else
			log "Installing $package..."
			sudo apt install -y "$package" || error "Failed to install $package"
		fi
	done <packages.txt

	success "Base packages installation completed"
}

# Install and setup Rust tools
setup_rust_tools() {
	if command_exists eza && command_exists yazi; then
		exists "All Rust tools already installed"
		return 0
	fi

	log "Setting up Rust tools..."
	source "$HOME/.cargo/env" || true

	if command_exists eza; then
		exists "eza already installed"
	else
		log "Installing eza..."
		cargo install eza || error "Failed to install eza"
	fi

	if command_exists yazi; then
		exists "yazi already installed"
	else
		log "Installing yazi..."
		cargo install yazi-fm || error "Failed to install yazi"
	fi

	success "Rust tools installation completed"
}

# Install Neovim from source
install_neovim() {
	if command_exists nvim; then
		current_version=$(nvim --version | head -n1)
		exists "Neovim already installed: $current_version"
		read -p "Do you want to reinstall? (y/N) " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			return
		fi
	fi

	log "Building Neovim from source..."
	BUILD_DIR="$(mktemp -d)"
	cd "$BUILD_DIR"

	git clone https://github.com/neovim/neovim
	cd neovim
	git checkout stable
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	sudo make install

	cd
	rm -rf "$BUILD_DIR"

	command -v nvim >/dev/null && success "Neovim installed!" || error "Neovim installation failed"
}

# Install Node.js via nvm
install_node() {
	# Check if nvm is installed
	if [ -d "$HOME/.nvm" ]; then
		exists "nvm already installed"

		# Load nvm
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

		# Check if Node 20 is installed
		if nvm ls | grep -q "v20"; then
			exists "Node.js 20 already installed"
			return
		fi
	else
		log "Installing nvm..."
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

		# Load nvm
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	fi

	# Install Node.js 20
	log "Installing Node.js 20..."
	nvm install 20
	nvm use 20
	nvm alias default 20

	success "Node.js setup completed"
}

# Install zoxide
install_zoxide() {
	if command_exists zoxide; then
		exists "zoxide already installed"
		return
	fi

	log "Installing zoxide..."
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
	success "Zoxide installed"
}

# Install lazygit
install_lazygit() {
	if command_exists lazygit; then
		exists "lazygit already installed"
		return
	fi

	log "Installing lazygit..."
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
	tar xf lazygit.tar.gz
	sudo install lazygit /usr/local/bin
	rm lazygit lazygit.tar.gz
	success "Lazygit installed"
}

# Install btop
install_btop() {
	if command_exists btop; then
		exists "btop already installed"
		return
	fi

	log "Installing btop..."
	BUILD_DIR="$(mktemp -d)"
	cd "$BUILD_DIR"

	git clone https://github.com/aristocratos/btop.git
	cd btop
	make
	sudo make install

	cd
	rm -rf "$BUILD_DIR"

	command -v btop >/dev/null && success "btop installed!" || error "btop installation failed"
}

# Install lazydocker
install_lazydocker() {
	if command_exists lazydocker; then
		exists "lazydocker already installed"
		return
	fi

	log "Installing lazydocker..."
	LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_arm64.tar.gz"
	tar xf lazydocker.tar.gz
	sudo install lazydocker /usr/local/bin
	rm lazydocker lazydocker.tar.gz
	success "Lazydocker installed"
}

# Setup fzf
setup_fzf() {
	if [ -f "$HOME/.zsh/tools/fzf/key-bindings.zsh" ] && [ -f "$HOME/.zsh/tools/fzf/completion.zsh" ]; then
		exists "fzf configuration already exists"
		return
	fi

	log "Setting up fzf..."
	mkdir -p "$HOME/.zsh/tools/fzf"

	curl -fLo "$HOME/.zsh/tools/fzf/key-bindings.zsh" \
		"https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
	curl -fLo "$HOME/.zsh/tools/fzf/completion.zsh" \
		"https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"

	if ! grep -q "source ~/.zsh/tools/fzf/key-bindings.zsh" "$HOME/.zshrc"; then
		echo "source ~/.zsh/tools/fzf/key-bindings.zsh" >>"$HOME/.zshrc"
		echo "source ~/.zsh/tools/fzf/completion.zsh" >>"$HOME/.zshrc"
	fi

	success "fzf setup completed"
}

# Setup Python tools
setup_python_tools() {
	log "Setting up Python tools..."

	if ! command_exists pip; then
		error "pip is not installed"
		return 1
	fi

	python3 -m pip install --user --upgrade pip

	if command_exists uv; then
		exists "uv already installed"
	else
		log "Installing uv..."
		python3 -m pip install --user uv || error "Failed to install uv"
	fi

	success "Python tools setup completed"
}

# Main installation
main() {
	log "Starting system setup..."

	# Count total steps
	local total=10 # Updated count to include btop
	local current=0

	# Run each step and show progress
	for step in setup_directories install_base_packages setup_rust_tools install_neovim \
		install_node install_zoxide install_lazygit install_lazydocker install_btop setup_fzf setup_python_tools; do
		((current++))
		log "[$current/$total] Running ${step}..."
		$step
	done

	echo ""
	success "Setup completed!"
	log "To finish setup, please run:"
	echo "    source ~/.zshrc"
	echo ""
}

main
