#!/bin/false
# shellcheck shell=bash

sudo pacman -S --needed git

mkdir -p "/home/$(whoami)/.config/systemd/user"
sudo ln -s "$PATHINSTANCE/newreleases/newreleases" "/usr/local/bin/newreleases"
ln -s "$PATHINSTANCE/newreleases/newreleases.service" "/home/$(whoami)/.config/systemd/user/newreleases.service"
ln -s "$PATHINSTANCE/newreleases/newreleases.timer" "/home/$(whoami)/.config/systemd/user/newreleases.timer"
sudo loginctl enable-linger
systemctl --user daemon-reload
systemctl --user enable --now newreleases.timer
systemctl --user status newreleases.timer
