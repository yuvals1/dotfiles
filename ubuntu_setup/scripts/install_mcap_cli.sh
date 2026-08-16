#!/usr/bin/env bash
#
# Installs the mcap CLI (github.com/foxglove/mcap) — pinned static Go
# binary; the standard decoder for treex_recording spines.

run_install_mcap_cli() {
    local version="v0.0.51"

    if command_exists mcap; then
        local installed
        installed="$(mcap version 2>/dev/null || true)"
        if [ "$installed" = "$version" ]; then
            exists "mcap CLI ${installed} already installed"
            return 0
        fi
        log "mcap CLI ${installed:-unknown} present; upgrading to ${version}"
    else
        log "Installing mcap CLI ${version}..."
    fi

    local arch
    case "$(uname -m)" in
        aarch64 | arm64) arch="arm64" ;;
        x86_64 | amd64) arch="amd64" ;;
        *)
            error "mcap CLI: unsupported architecture $(uname -m)"
            return 1
            ;;
    esac

    local url="https://github.com/foxglove/mcap/releases/download/releases%2Fmcap-cli%2F${version}/mcap-linux-${arch}"
    local tmp
    tmp="$(mktemp)"

    if ! curl -fsSL -o "$tmp" "$url"; then
        rm -f "$tmp"
        error "mcap CLI download failed"
        return 1
    fi
    chmod 755 "$tmp"

    if ! "$tmp" version >/dev/null 2>&1; then
        rm -f "$tmp"
        error "mcap CLI binary failed its version check"
        return 1
    fi

    sudo mv "$tmp" /usr/local/bin/mcap >/dev/null 2>&1 || {
        rm -f "$tmp"
        error "mcap CLI install to /usr/local/bin failed"
        return 1
    }
    sudo chmod 755 /usr/local/bin/mcap

    success "mcap CLI $(mcap version) installed"
}
