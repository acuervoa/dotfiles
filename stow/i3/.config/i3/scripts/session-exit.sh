#!/usr/bin/env bash

set -u

systemctl --user stop i3-session.target 2>/dev/null || true
systemctl --user stop graphical-session.target 2>/dev/null || true

exec i3-msg exit
