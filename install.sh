#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#   KAIROX v5 — ELITE INSTALLER
#   Author : Shadly Maliyekkal
#   Usage  : sudo bash install.sh
# ═══════════════════════════════════════════════════════════════════════════════

# ── Colours ──────────────────────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'
C='\033[0;36m'; M='\033[0;35m'; W='\033[1;37m'; DM='\033[2m'
BLD='\033[1m'; NC='\033[0m'; UL='\033[4m'

# ── Cursor ────────────────────────────────────────────────────────────────────
hide_cursor() { tput civis 2>/dev/null; }
show_cursor() { tput cnorm 2>/dev/null; }
trap 'show_cursor; echo ""' EXIT INT TERM

# ── Spinner ───────────────────────────────────────────────────────────────────
SP_PID=""
SP_FRAMES=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

spinner_start() {
    hide_cursor
    local label="$1"
    ( i=0
      while true; do
          f="${SP_FRAMES[$((i % ${#SP_FRAMES[@]}))]}"
          printf "\r  ${C}${f}${NC}  ${W}%-58s${NC}" "$label"
          sleep 0.07; ((i++))
      done ) &
    SP_PID=$!
}

_kill_spinner() {
    [ -n "$SP_PID" ] && kill "$SP_PID" 2>/dev/null && wait "$SP_PID" 2>/dev/null
    SP_PID=""
}

spinner_ok()   { _kill_spinner; printf "\r  ${G}✔${NC}  ${W}%-58s${NC}  ${DM}done${NC}\n" "$1"; show_cursor; }
spinner_skip() { _kill_spinner; printf "\r  ${C}◈${NC}  ${W}%-58s${NC}  ${DM}already installed${NC}\n" "$1"; show_cursor; }
spinner_warn() { _kill_spinner; printf "\r  ${Y}⚠${NC}  ${W}%-58s${NC}  ${Y}$2${NC}\n" "$1"; show_cursor; }
spinner_fail() { _kill_spinner; printf "\r  ${R}✘${NC}  ${W}%-58s${NC}  ${R}$2${NC}\n" "$1"; show_cursor; }

section() {
    echo ""
    echo -e "  ${BLD}${C}╔══════════════════════════════════════════════════════════╗${NC}"
    printf "  ${BLD}${C}║${NC}  ${BLD}${M}%-56s${NC}  ${BLD}${C}║${NC}\n" "◈  $*"
    echo -e "  ${BLD}${C}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ── Banner ────────────────────────────────────────────────────────────────────
clear
echo ""
echo -e "${C}${BLD}"
echo '  ██╗  ██╗ █████╗ ██╗██████╗  ██████╗ ██╗  ██╗'
echo '  ██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗╚██╗██╔╝'
echo '  █████╔╝ ███████║██║██████╔╝██║   ██║ ╚███╔╝ '
echo '  ██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║ ██╔██╗ '
echo '  ██║  ██╗██║  ██║██║██║  ██║╚██████╔╝██╔╝ ██╗'
echo '  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝'
echo -e "${NC}"
echo -e "  ${BLD}${G}KAIROX v5${NC}  ${DM}—  Elite Recon & Vulnerability Platform${NC}  ${DM}by Shadly Maliyekkal${NC}"
echo -e "  ${DM}${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

OS="$(uname -s)"
ARCH="$(uname -m)"
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# ── Check root / sudo ─────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    if ! sudo -n true 2>/dev/null; then
        echo -e "  ${Y}⚠${NC}  This installer needs sudo. You may be prompted for your password."
        echo ""
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
section "File Sanity Check"
# ─────────────────────────────────────────────────────────────────────────────
for f in install.sh kairox; do
    if [ -f "$f" ]; then
        spinner_start "Fixing: $f"
        tr -d '\r' < "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
        chmod +x "$f"
        spinner_ok "Fixed + chmod +x: $f"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
section "Python 3 + pip + Dependencies"
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    spinner_start "Installing python3"
    sudo apt-get install -y python3 python3-pip &>/dev/null 2>&1 || \
    sudo dnf install -y python3 python3-pip &>/dev/null 2>&1
    command -v python3 &>/dev/null && spinner_ok "python3" || spinner_fail "python3" "install failed"
else
    spinner_skip "python3 ($(python3 --version 2>&1))"
fi

install_pip() {
    local pkg="$1" imp="${2:-$1}"
    python3 -c "import $imp" &>/dev/null 2>&1 && { spinner_skip "pip: $pkg"; return; }
    spinner_start "pip install: $pkg"
    python3 -m pip install "$pkg" --break-system-packages -q &>/dev/null 2>&1 || \
    pip3 install "$pkg" --break-system-packages -q &>/dev/null 2>&1 || true
    python3 -c "import $imp" &>/dev/null 2>&1 \
        && spinner_ok "pip: $pkg" \
        || spinner_warn "pip: $pkg" "may need manual install"
}

install_pip "rich"
install_pip "requests"
install_pip "dnspython" "dns"
install_pip "wafw00f" "wafw00f"
install_pip "psutil"

# ─────────────────────────────────────────────────────────────────────────────
section "System Tools"
# ─────────────────────────────────────────────────────────────────────────────

apt_install() {
    local name="$1" pkg="${2:-$1}"
    command -v "$name" &>/dev/null && { spinner_skip "$name"; return; }
    spinner_start "Installing: $name"
    sudo apt-get install -y -qq "$pkg" &>/dev/null 2>&1
    command -v "$name" &>/dev/null && spinner_ok "$name" || spinner_warn "$name" "not in apt"
}

if command -v apt-get &>/dev/null; then
    spinner_start "Updating package index"
    sudo apt-get update -qq &>/dev/null 2>&1
    spinner_ok "Package index updated"

    for pkg in nmap nikto sslscan dnsrecon curl wget whois git openssl unzip masscan \
                hydra sqlmap dirb gobuster whatweb dnsenum wapiti fierce; do
        apt_install "$pkg"
    done

    # Kali-aware name:package mappings (binary name differs from package name)
    apt_install "nc"       "netcat-traditional"  # netcat-openbsd not in Kali repos
    apt_install "host"     "bind9-host"           # 'host' binary is in bind9-host
    apt_install "dig"      "dnsutils"             # dig + nslookup in dnsutils
    apt_install "nslookup" "dnsutils"

    spinner_start "Installing libpcap-dev"
    sudo apt-get install -y -qq libpcap-dev &>/dev/null 2>&1
    spinner_ok "libpcap-dev"

    spinner_start "Installing chromium (for katana JS crawling)"
    sudo apt-get install -y -qq chromium chromium-driver &>/dev/null 2>&1 || true
    spinner_ok "chromium (optional)"

    # testssl.sh
    if ! command -v testssl.sh &>/dev/null && [ ! -f /usr/local/bin/testssl.sh ]; then
        spinner_start "Installing testssl.sh"
        sudo apt-get install -y -qq testssl.sh &>/dev/null 2>&1
        if ! command -v testssl.sh &>/dev/null; then
            sudo curl -fsSL "https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh" \
                 -o /usr/local/bin/testssl.sh &>/dev/null 2>&1 && sudo chmod +x /usr/local/bin/testssl.sh
            [ -s /usr/local/bin/testssl.sh ] && spinner_ok "testssl.sh" || spinner_warn "testssl.sh" "download failed"
        else
            spinner_ok "testssl.sh"
        fi
    else
        spinner_skip "testssl.sh"
    fi

elif command -v dnf &>/dev/null; then
    spinner_start "Updating package index (dnf)"
    sudo dnf check-update -q &>/dev/null 2>&1 || true
    spinner_ok "Package index updated"
    for pkg in nmap curl wget whois git openssl unzip masscan nmap-ncat; do
        command -v "$pkg" &>/dev/null && { spinner_skip "$pkg"; continue; }
        spinner_start "Installing: $pkg"
        sudo dnf install -y -q "$pkg" &>/dev/null 2>&1
        command -v "$pkg" &>/dev/null && spinner_ok "$pkg" || spinner_warn "$pkg" "dnf failed"
    done
    spinner_start "Installing libpcap-devel"
    sudo dnf install -y -q libpcap-devel &>/dev/null 2>&1 && spinner_ok "libpcap-devel"
fi

# ─────────────────────────────────────────────────────────────────────────────
section "Go Language Runtime"
# ─────────────────────────────────────────────────────────────────────────────
install_go() {
    local VER="1.22.4"
    local FILE
    case "$OS-$ARCH" in
        Linux-x86_64)              FILE="go${VER}.linux-amd64.tar.gz" ;;
        Linux-aarch64|Linux-arm64) FILE="go${VER}.linux-arm64.tar.gz" ;;
        Linux-armv6l|Linux-armv7l) FILE="go${VER}.linux-armv6l.tar.gz" ;;
        Darwin-arm64)              FILE="go${VER}.darwin-arm64.tar.gz" ;;
        Darwin-x86_64)             FILE="go${VER}.darwin-amd64.tar.gz" ;;
        *) spinner_warn "Go" "Unsupported: $OS/$ARCH"; return 1 ;;
    esac
    local TMP="/tmp/kx5_go_$$"
    mkdir -p "$TMP"
    spinner_start "Downloading Go ${VER}"
    curl -fsSL "https://go.dev/dl/${FILE}" -o "$TMP/$FILE" 2>/dev/null || \
    wget -q "https://go.dev/dl/${FILE}" -O "$TMP/$FILE" 2>/dev/null
    [ -s "$TMP/$FILE" ] || { spinner_fail "Go download" "network error"; rm -rf "$TMP"; return 1; }
    spinner_ok "Go downloaded"
    spinner_start "Installing Go to /usr/local"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$TMP/$FILE" &>/dev/null 2>&1
    rm -rf "$TMP"
    export PATH="$PATH:/usr/local/go/bin"
    command -v go &>/dev/null && spinner_ok "Go $(go version)" || spinner_fail "Go" "install failed"
}

command -v go &>/dev/null && spinner_skip "Go ($(go version))" || install_go

# ─────────────────────────────────────────────────────────────────────────────
section "Go PATH Setup"
# ─────────────────────────────────────────────────────────────────────────────
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
mkdir -p "$GOPATH/bin"

spinner_start "Configuring shell PATH"
for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$RC" ] || [ "$RC" = "$HOME/.bashrc" ] || continue
    touch "$RC" 2>/dev/null
    grep -q "/usr/local/go/bin" "$RC" 2>/dev/null || echo 'export PATH=$PATH:/usr/local/go/bin' >> "$RC"
    grep -q 'go/bin' "$RC" 2>/dev/null           || echo 'export PATH=$PATH:$HOME/go/bin'       >> "$RC"
done
spinner_ok "PATH configured (.bashrc .zshrc .profile)"

# ─────────────────────────────────────────────────────────────────────────────
section "Go Security Tools"
# ─────────────────────────────────────────────────────────────────────────────
go_install() {
    local name="$1" pkg="$2" desc="$3"
    command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ] && { spinner_skip "$name ($desc)"; return; }
    command -v go &>/dev/null || { spinner_warn "$name" "Go unavailable"; return; }
    spinner_start "go install: $name  [$desc]"
    GOPATH="$GOPATH" go install "${pkg}@latest" &>/dev/null 2>&1
    ( command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ] ) \
        && spinner_ok "$name" || spinner_warn "$name" "check manually"
}

go_install "subfinder"   "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"  "subdomain enum"
go_install "httpx"       "github.com/projectdiscovery/httpx/cmd/httpx"             "live host + tech"
go_install "dnsx"        "github.com/projectdiscovery/dnsx/cmd/dnsx"               "dns resolver"
go_install "nuclei"      "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"        "vuln templates"
go_install "naabu"       "github.com/projectdiscovery/naabu/v2/cmd/naabu"          "port scanner"
go_install "katana"      "github.com/projectdiscovery/katana/cmd/katana"           "js crawler"
go_install "gau"         "github.com/lc/gau/v2/cmd/gau"                            "url archive"
go_install "waybackurls" "github.com/tomnomnom/waybackurls"                        "wayback"
go_install "ffuf"        "github.com/ffuf/ffuf/v2"                                 "fuzzer"
go_install "anew"        "github.com/tomnomnom/anew"                               "dedup"
go_install "hakrawler"   "github.com/hakluke/hakrawler"                            "web crawler"
go_install "assetfinder" "github.com/tomnomnom/assetfinder"                        "subdomain find"
go_install "gf"          "github.com/tomnomnom/gf"                                 "grep patterns"
go_install "dalfox"      "github.com/hahwul/dalfox/v2"                             "xss scanner"
go_install "interactsh-client" "github.com/projectdiscovery/interactsh/cmd/interactsh-client" "oob testing"

# ─────────────────────────────────────────────────────────────────────────────
section "Nuclei Templates"
# ─────────────────────────────────────────────────────────────────────────────
NBIN=""; command -v nuclei &>/dev/null && NBIN="nuclei"
[ -f "$GOPATH/bin/nuclei" ] && NBIN="$GOPATH/bin/nuclei"

if [ -n "$NBIN" ]; then
    spinner_start "Updating nuclei templates"
    "$NBIN" -update-templates &>/dev/null 2>&1
    spinner_ok "Nuclei templates updated"
else
    spinner_warn "Nuclei templates" "nuclei not installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
section "amass"
# ─────────────────────────────────────────────────────────────────────────────
if command -v amass &>/dev/null || [ -f "$GOPATH/bin/amass" ]; then
    spinner_skip "amass"
elif command -v snap &>/dev/null; then
    spinner_start "snap install amass"
    sudo snap install amass &>/dev/null 2>&1 && spinner_ok "amass (snap)" || spinner_warn "amass" "snap failed"
elif command -v go &>/dev/null; then
    spinner_start "go install amass"
    go install github.com/owasp-amass/amass/v4/...@latest &>/dev/null 2>&1
    ( command -v amass &>/dev/null || [ -f "$GOPATH/bin/amass" ] ) && spinner_ok "amass" || spinner_warn "amass" "failed"
else
    spinner_warn "amass" "not available"
fi

# ─────────────────────────────────────────────────────────────────────────────
section "SecLists Wordlists"
# ─────────────────────────────────────────────────────────────────────────────
if [ -d /usr/share/seclists ] || [ -d /usr/share/SecLists ]; then
    spinner_skip "SecLists"
elif command -v apt-get &>/dev/null; then
    spinner_start "Installing SecLists (apt)"
    sudo apt-get install -y -qq seclists &>/dev/null 2>&1
    [ -d /usr/share/seclists ] && spinner_ok "SecLists (apt)" || {
        spinner_start "Cloning SecLists"
        sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists &>/dev/null 2>&1
        [ -d /usr/share/seclists ] && spinner_ok "SecLists cloned" || spinner_warn "SecLists" "clone failed"
    }
else
    spinner_start "Cloning SecLists"
    sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists &>/dev/null 2>&1
    [ -d /usr/share/seclists ] && spinner_ok "SecLists" || spinner_warn "SecLists" "clone failed"
fi

# ─────────────────────────────────────────────────────────────────────────────
section "Final Status"
# ─────────────────────────────────────────────────────────────────────────────

echo -e "  ${C}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${C}║${NC}            ${BLD}${W}KAIROX v5 — TOOL STATUS REPORT${NC}              ${C}║${NC}"
echo -e "  ${C}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

ALL_TOOLS=(
    "go:Go runtime"
    "python3:Python 3"
    "subfinder:Subdomain enum"
    "amass:OSINT enum"
    "assetfinder:Subdomain finder"
    "httpx:Live host probe"
    "dnsx:DNS resolver"
    "nuclei:Vuln templates"
    "naabu:Port scanner"
    "katana:JS crawler"
    "hakrawler:Web crawler"
    "gau:URL archive"
    "waybackurls:Wayback URLs"
    "ffuf:Directory fuzzer"
    "dalfox:XSS scanner"
    "nmap:Port + service scan"
    "masscan:Fast port scan"
    "nikto:Web vuln scan"
    "whatweb:Tech fingerprint"
    "sslscan:SSL audit"
    "testssl.sh:Deep SSL audit"
    "wafw00f:WAF detection"
    "dnsrecon:DNS recon"
    "gobuster:Dir bruteforce"
    "sqlmap:SQLi scanner"
    "hydra:Auth bruteforce"
    "curl:HTTP fallback"
    "wget:Downloader"
    "whois:WHOIS lookup"
    "openssl:Cert analysis"
)

INSTALLED=0; MISSING=()
for entry in "${ALL_TOOLS[@]}"; do
    name="${entry%%:*}"; desc="${entry##*:}"
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ] || [ -f "/usr/local/bin/$name" ]; then
        printf "  ${G}✔${NC}  %-22s ${DM}%s${NC}\n" "$name" "$desc"
        ((INSTALLED++))
    else
        printf "  ${Y}✘${NC}  %-22s ${Y}missing — fallback active${NC}\n" "$name"
        MISSING+=("$name")
    fi
done

echo ""
echo -e "  ${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BLD}${G}  ${INSTALLED}/${#ALL_TOOLS[@]} tools ready${NC}"
echo ""
echo -e "  ${BLD}Launch:${NC}  ${C}./kairox${NC}   or   ${C}python3 kairox${NC}"
echo ""

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "  ${Y}Missing:${NC} ${MISSING[*]}"
    echo -e "  ${DM}KAIROX v5 uses smart fallbacks for missing tools.${NC}"
    echo ""
fi

echo -e "  ${DM}Reload PATH:${NC}  ${C}source ~/.bashrc && ./kairox${NC}"
echo ""
