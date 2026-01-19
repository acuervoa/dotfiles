#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# MEM usada = MemTotal - MemAvailable (más real que 'free')
read -r total_kb < <(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
read -r avail_kb < <(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
used_kb=$(( total_kb - avail_kb ))

to_gi() { awk -v kb="$1" 'BEGIN{printf "%.1fGi", kb/1048576}'; }
pct()   { awk -v u="$1" -v t="$2" 'BEGIN{printf "(%2.0f%%)", (u/t)*100}'; }

printf "%s/%s %s\n" "$(to_gi "$used_kb")" "$(to_gi "$total_kb")" "$(pct "$used_kb" "$total_kb")"

