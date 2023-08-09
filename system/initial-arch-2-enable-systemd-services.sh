#!/bin/bash
set -eo pipefail

[[ $EUID -eq 0 ]] && { echo "> don't run this as root"; exit 1; }

set -x
systemctl --user enable --now ssh-agent.service
systemctl --user enable --now i3status-additional.service
sudo systemctl enable --now lightdm.service
