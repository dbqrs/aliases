#!/usr/bin/env bash
set -euo pipefail

cd "$HOME" || { echo "Error: Unable to change to home directory"; exit 1; }

# Update apt, install jq and curl
sudo apt update
sudo apt install -y jq curl

# Ensure ~/.loggy exists
mkdir -p "$HOME/.loggy"

BASHRC="$HOME/.bashrc"
touch "$BASHRC"

# Backup the current .bashrc
cp -f -- "$BASHRC" "$HOME/.bashrc.backup"

# The block we want to append
#### Begin append ~/.bashrc
BASHRC_BLOCK="$(cat <<'EOF'

alias cls='clear'
alias update='sudo apt update && sudo apt upgrade -y 2>&1 | tee ~/.loggy/"$(date +%F-%S)-upgrade.log"'
alias cleanup='sudo apt autoremove && sudo apt autoclean && sudo apt clean'
alias wget='wget -c'
alias sctl='sudo systemctl'
alias pinger='ping -i 1 -s 1472 8.8.8.8 | while read line; do echo "$(date "+%Y-%m-%d %H:%M:%S") - $line"; done'
alias mip="ip -o -4 addr show | awk '{print \$2, \$4}'"
alias install='sudo apt install'
alias dpkg='sudo dpkg -i'
alias nn='neofetch'
alias ff='fastfetch'
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'

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
EOF
)"
#### End append ~/.bashrc

# Append once
if ! grep -Fq '#### Begin append ~/.bashrc' "$BASHRC"; then
  printf "\n%s\n" "$BASHRC_BLOCK" >> "$BASHRC"
  echo "Appended aliases/functions to $BASHRC"
else
  echo "Block already present; skipping append."
fi

# Quick syntax check
bash -n "$BASHRC" || { echo "Warning: $BASHRC has syntax errors."; exit 1; }

# Apply to the *current* shell (avoid .bashrc's non-interactive early return)
eval "$BASHRC_BLOCK"

echo "Done."
