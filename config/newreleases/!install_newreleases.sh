#!/bin/false
# shellcheck shell=bash

sudo pacman -S --needed git

mkdir -p "/home/$(whoami)/.config/systemd/user"
sudo ln -sf "$PATHINSTANCE/config/newreleases/newreleases" "/usr/local/bin/newreleases"
ln -sf "$PATHINSTANCE/config/newreleases/newreleases.service" "/home/$(whoami)/.config/systemd/user/newreleases.service"
ln -sf "$PATHINSTANCE/config/newreleases/newreleases.timer" "/home/$(whoami)/.config/systemd/user/newreleases.timer"
sudo loginctl enable-linger
systemctl --user daemon-reload
systemctl --user enable --now newreleases.timer
systemctl --user status newreleases.timer
