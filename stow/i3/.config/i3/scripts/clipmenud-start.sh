#!/usr/bin/env bash

set -u

systemctl --user import-environment DISPLAY XAUTHORITY
systemctl --user reset-failed clipmenud.service
systemctl --user restart clipmenud.service
