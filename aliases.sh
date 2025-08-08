#!/usr/bin/env bash
set -euo pipefail

# Always work from the home directory
cd "$HOME" || { echo "Error: Unable to change to home directory"; exit 1; }

# Update apt. Install jq, neofetch and curl
sudo apt update
sudo apt install -y jq neofetch curl

# Create log directory ~/.loggy
mkdir -p "$HOME/.loggy"

# Append the config block to ~/.bashrc (once)
BASHRC="${HOME}/.bashrc"
touch "$BASHRC"

read -r -d '' BASHRC_BLOCK <<'EOF'
#### Begin append ~/.bashrc
alias cls='clear'
alias update='sudo apt update && sudo apt upgrade -y 2>&1 | tee ~/.loggy/"$(date +%F-%S)-upgrade.log"'
alias cleanup='sudo apt autoremove && sudo apt autoclean && sudo apt clean'
alias wget='wget -c'
alias sctl='sudo systemctl'
alias pinger='ping -i 1 -s 1472 8.8.8.8 | while read line; do echo "$(date "+%Y-%m-%d %H:%M:%S") - $line"; done'
alias mip="ip -o -4 addr show | awk '{print \$2, \$4}'"
alias apt='sudo apt'
alias dpkg='sudo dpkg'

# Pubip
pub() {
    local api_url="http://ipinfo.io/json"
    if command -v jq >/dev/null 2>&1; then
        curl -s "$api_url" | jq -r '
            "IP: \(.ip)",
            "Hostname: \(.hostname)",
            "City: \(.city)",
            "Region: \(.region)",
            "Country: \(.country)",
            "Org: \(.org)"
        '
    else
        echo "jq is required but not installed. Install jq and try again."
    fi
}
#### End append ~/.bashrc
EOF

if ! grep -Fq '#### Begin append ~/.bashrc' "$BASHRC"; then
  printf "\n%s\n" "$BASHRC_BLOCK" >> "$BASHRC"
  echo "Appended aliases/functions to $BASHRC"
else
  echo "Block already present; skipping append."
fi

# Quick sanity check for syntax errors
bash -n "$BASHRC" || { echo "Warning: $BASHRC has syntax errors."; exit 1; }

# Source the updated ~/.bashrc so changes take effect immediately
# shellcheck disable=SC1090
. "$BASHRC"

echo "Done. Aliases and functions have been applied to your current shell."
