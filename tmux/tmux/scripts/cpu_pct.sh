#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

STATE="/tmp/tmux_cpu_${USER}.state"

# Lee /proc/stat (línea 'cpu')
# Campos: user nice system idle iowait irq softirq steal guest guest_nice
read -r _ u n s i w irq sirq st _ < /proc/stat

idle=$(( i + w ))
nonidle=$(( u + n + s + irq + sirq + st ))
total=$(( idle + nonidle ))

if [[ -f "$STATE" ]]; then
  read -r prev_total prev_idle < "$STATE" || { printf "0%%\n"; echo "$total $idle" > "$STATE"; exit 0; }
  dt=$(( total - prev_total ))
  didle=$(( idle - prev_idle ))
  (( dt <= 0 )) && { printf "0%%\n"; echo "$total $idle" > "$STATE"; exit 0; }
  # Uso = (dt - didle) / dt
  awk -v dt="$dt" -v di="$didle" 'BEGIN{printf "%d%%\n", int( (dt - di)*100.0/dt + 0.5)}'
else
  printf "0%%\n"
fi

echo "$total $idle" > "$STATE"

