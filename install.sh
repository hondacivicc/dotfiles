#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[dotfiles]${NC} $1"; }
info() { echo -e "${CYAN}[dotfiles]${NC} $1"; }
warn() { echo -e "${YELLOW}[dotfiles]${NC} $1"; }
die()  { echo -e "${RED}[dotfiles]${NC} $1"; exit 1; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --packages    Install required packages via pacman/yay"
    echo "  --link        Create symlinks only (skip package install)"
    echo "  --all         Install packages and create symlinks"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Running with no options is equivalent to --all (prompts before each step)."
}

# ─── Package lists ────────────────────────────────────────────────────────────

PACMAN_PKGS=(
    hyprland
    hyprpaper
    waybar
    rofi
    dunst
    alacritty
    kitty
    nautilus
    grim
    slurp
    swappy
    wf-recorder
    brightnessctl
    playerctl
    wireplumber
    polkit-kde-agent
    btop
    neovim
    fish
    fastfetch
    qt6ct
)

AUR_PKGS=(
    awww
    brave-bin
    vesktop
    cava
)

# ─── Helpers ──────────────────────────────────────────────────────────────────

confirm() {
    local prompt="${1:-Continue?}"
    read -rp "$(echo -e "${YELLOW}${prompt}${NC} [y/N] ")" ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

ensure_yay() {
    if command -v yay &>/dev/null; then return; fi
    warn "yay not found — installing from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

install_packages() {
    info "Packages to install via pacman: ${PACMAN_PKGS[*]}"
    info "Packages to install via yay (AUR): ${AUR_PKGS[*]}"
    echo ""

    log "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

    log "Installing AUR packages..."
    ensure_yay
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"

    log "Package installation complete."
}

# ─── Symlink helpers ──────────────────────────────────────────────────────────

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        warn "Backing up existing $(basename "$target") → $(basename "$target").bak"
        mv "$target" "${target}.bak"
    fi
}

link_config() {
    local name="$1"
    local src="$DOTFILES_DIR/.config/$name"
    local dst="$CONFIG_DIR/$name"

    if [ ! -e "$src" ]; then
        warn "Source not found, skipping: $src"
        return
    fi

    backup_if_exists "$dst"
    ln -sfn "$src" "$dst"
    log "  linked ~/.config/$name"
}

link_file() {
    # link_file ".config/brave-flags.conf"  →  $HOME/.config/brave-flags.conf
    local rel="$1"
    local src="$DOTFILES_DIR/$rel"
    local dst="$HOME/$rel"

    if [ ! -e "$src" ]; then
        warn "Source not found, skipping: $src"
        return
    fi

    mkdir -p "$(dirname "$dst")"
    backup_if_exists "$dst"
    ln -sfn "$src" "$dst"
    log "  linked ~/$rel"
}

create_symlinks() {
    mkdir -p "$CONFIG_DIR"

    log "Creating config symlinks..."

    # Whole config directories
    for name in hypr waybar rofi kitty alacritty fish btop cava nvim gtk-3.0 gtk-4.0 qt6ct swappy; do
        link_config "$name"
    done

    # Individual files
    link_file ".config/brave-flags.conf"

    log "Symlinks created."
}

# ─── Wallpaper notice ─────────────────────────────────────────────────────────

wallpaper_notice() {
    echo ""
    warn "Wallpapers are NOT tracked in this repo (too large for git)."
    info "Place your wallpapers in the following directories:"
    info "  ~/.config/wallpapers/wallpaper1/          (cycling wallpapers)"
    info "  ~/.config/wallpapers/wallpaper2/day/      (time-based: 06:00–18:00)"
    info "  ~/.config/wallpapers/wallpaper2/night/    (time-based: 18:00–06:00)"
    echo ""
    info "Then update ~/.config/hypr/hyprpaper.conf with a valid wallpaper path."

    mkdir -p "$CONFIG_DIR/wallpapers/wallpaper1"
    mkdir -p "$CONFIG_DIR/wallpapers/wallpaper2/day"
    mkdir -p "$CONFIG_DIR/wallpapers/wallpaper2/night"
    mkdir -p "$CONFIG_DIR/wallpapers/wallpaper2/tmp"
}

# ─── Shell setup ─────────────────────────────────────────────────────────────

set_fish_shell() {
    local fish_path
    fish_path="$(command -v fish 2>/dev/null || true)"

    if [ -z "$fish_path" ]; then
        warn "fish not found in PATH, skipping shell change."
        return
    fi

    if [ "$SHELL" = "$fish_path" ]; then
        info "fish is already the default shell."
        return
    fi

    # Ensure fish is in /etc/shells
    if ! grep -qF "$fish_path" /etc/shells; then
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi

    chsh -s "$fish_path"
    log "Default shell changed to fish. Re-login to take effect."
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    local do_packages=false
    local do_link=false
    local interactive=true

    for arg in "$@"; do
        case "$arg" in
            --packages) do_packages=true; interactive=false ;;
            --link)     do_link=true;     interactive=false ;;
            --all)      do_packages=true; do_link=true; interactive=false ;;
            -h|--help)  usage; exit 0 ;;
            *) die "Unknown option: $arg" ;;
        esac
    done

    echo -e "${CYAN}"
    echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
    echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
    echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
    echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
    echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
    echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${NC}"
    info "Dotfiles installer — Hyprland + CachyOS"
    echo ""

    if $interactive; then
        confirm "Install packages (pacman + AUR)?" && do_packages=true
        confirm "Create config symlinks?" && do_link=true
    fi

    $do_packages && install_packages
    $do_link     && create_symlinks

    if $do_link; then
        wallpaper_notice
        confirm "Set fish as default shell?" && set_fish_shell
    fi

    echo ""
    log "All done! Log out and back in (or reboot) to start Hyprland."
    info "Launch Hyprland from a TTY with: Hyprland"
}

main "$@"
