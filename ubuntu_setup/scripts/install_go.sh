#!/usr/bin/env bash
# Installs or upgrades Go on Ubuntu.
# - Uses apt if Go is missing and version is recent enough
# - Otherwise installs latest stable from go.dev tarball into /usr/local/go
# - Ensures /usr/local/bin/go points to the new toolchain

_min_version() {
  # compare two semver-ish versions (major.minor[.patch])
  # returns 0 if $1 >= $2
  python3 - <<'PY' "$1" "$2"
import sys
from itertools import zip_longest

def parse(v):
    return [int(x) for x in v.strip().lstrip('go').split('.') if x.isdigit()]

a=parse(sys.argv[1]); b=parse(sys.argv[2])
for x,y in zip_longest(a,b,fillvalue=0):
    if x>y: sys.exit(0)
    if x<y: sys.exit(1)
sys.exit(0)
PY
}

_detect_arch() {
  local u=$(uname -m)
  case "$u" in
    aarch64|arm64) echo "arm64" ;;
    x86_64|amd64)  echo "amd64" ;;
    *) echo "$u" ;;
  esac
}

_install_tarball() {
  local want="$1" arch="$2"
  local tarball="${want}.linux-${arch}.tar.gz"
  local url="https://go.dev/dl/${tarball}"
  log "Downloading ${url}"
  curl -fsSL -o "/tmp/${tarball}" "$url" || error "Failed downloading $url"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "/tmp/${tarball}" || error "Failed extracting Go tarball"
  sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
  sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
  rm -f "/tmp/${tarball}"
  success "Installed $(/usr/local/go/bin/go version)"
}

run_install_go() {
  local MIN="1.22"   # minimal acceptable Go for our tools
  # If lazygit repo exists, parse its go.mod required version and raise MIN
  if [ -f "$HOME/dev/lazygit/go.mod" ]; then
    local REQ
    REQ=$(grep -E '^go\s+' "$HOME/dev/lazygit/go.mod" | awk '{print $2}' | head -n1)
    if [ -n "$REQ" ]; then
      # normalize like 1.24.0 -> 1.24
      REQ=${REQ%.*}
      if ! _min_version "${MIN}" "${REQ}" ; then
        MIN="$REQ"
      fi
    fi
  fi

  local has_go=0 cur=""
  if command -v go >/dev/null 2>&1; then
    has_go=1
    cur=$(go version 2>/dev/null | awk '{print $3}')
  fi

  if [ "$has_go" -eq 0 ]; then
    log "Installing Go via apt (bootstrap) ..."
    sudo apt update -y || error "Failed to apt update"
    sudo apt install -y golang-go || sudo apt install -y golang || true
    if command -v go >/dev/null 2>&1; then
      cur=$(go version 2>/dev/null | awk '{print $3}')
      exists "Go installed via apt: $(go version)"
    fi
  fi

  # Decide if we need to upgrade to latest tarball
  if [ -n "$cur" ] && _min_version "$cur" "go${MIN}" ; then
    exists "Go already installed: $(go version) (meets >= ${MIN})"
    return
  fi

  # Install latest stable from go.dev
  local want
  want=$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)
  if [ -z "$want" ]; then
    error "Could not determine latest Go version"
  fi
  local arch=$(_detect_arch)
  log "Installing ${want} for ${arch}"
  _install_tarball "$want" "$arch"
}
