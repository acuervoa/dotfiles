#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Uso:
#   IF_OVERRIDE=enp2s0 ~/.tmux/scripts/net_kis.sh
#   PLAIN=1 IF_OVERRIDE=enp2s0 ~/.tmux/scripts/net_kis.sh   # => "RX_Ki_s TX_Ki_s"
#
# Estados en /tmp: diferencia por segundo usando /proc/uptime (monotónico)

choose_if() {
  if [[ -n "${IF_OVERRIDE:-}" ]]; then
    echo "$IF_OVERRIDE"; return
  fi
  local dif
  dif=$(ip -o route show default 2>/dev/null | awk '{print $5; exit}' || true)
  if [[ -n "${dif:-}" && -r "/sys/class/net/$dif/operstate" ]] &&
     grep -q up "/sys/class/net/$dif/operstate"; then
    echo "$dif"; return
  fi
  for dev in /sys/class/net/*; do
    local name; name=$(basename "$dev")
    [[ "$name" == "lo" ]] && continue
    [[ "$name" =~ ^(veth|docker|br-|vmnet|tun|tap) ]] && continue
    [[ -r "$dev/operstate" ]] && grep -q up "$dev/operstate" && { echo "$name"; return; }
  done
  ls -1 /sys/class/net | grep -v '^lo$' | head -n1
}

IF=$(choose_if || true)
[[ -z "${IF:-}" ]] && { [[ -n "${PLAIN:-}" ]] && echo "0 0" || echo "0Ki/s↓ 0Ki/s↑"; exit 0; }

RX_FILE="/sys/class/net/$IF/statistics/rx_bytes"
TX_FILE="/sys/class/net/$IF/statistics/tx_bytes"
[[ -r "$RX_FILE" && -r "$TX_FILE" ]] || { [[ -n "${PLAIN:-}" ]] && echo "0 0" || echo "0Ki/s↓ 0Ki/s↑"; exit 0; }

STATE="/tmp/tmux_net_${USER}_${IF}.state"

RX=$(< "$RX_FILE") || RX=0
TX=$(< "$TX_FILE") || TX=0
# Tiempo monotónico (segundos desde arranque)
read -r SEC _ < /proc/uptime
TS=${SEC%%.*}

if [[ -f "$STATE" ]]; then
  read -r prx ptx pts < "$STATE" 2>/dev/null || { prx=$RX; ptx=$TX; pts=$TS; }
else
  # primera vez: no hay delta
  printf "%s %s %s\n" "$RX" "$TX" "$TS" > "$STATE"
  [[ -n "${PLAIN:-}" ]] && echo "0 0" || echo "0Ki/s↓ 0Ki/s↑"
  exit 0
fi

dt=$(( TS - pts )); (( dt < 1 )) && dt=1
r_kis=$(( (RX - prx) / 1024 / dt )); (( r_kis < 0 )) && r_kis=0
t_kis=$(( (TX - ptx) / 1024 / dt )); (( t_kis < 0 )) && t_kis=0

# Persistir nuevo estado
printf "%s %s %s\n" "$RX" "$TX" "$TS" > "$STATE"

if [[ -n "${PLAIN:-}" ]]; then
  # salida cruda: "RX_Ki_s TX_Ki_s"
  printf "%d %d\n" "$r_kis" "$t_kis"
else
  # salida bonita para compatibilidad
  human() {
    local kis=$1
    if   (( kis >= 1024*1024 )); then
      awk -v v="$kis" 'BEGIN{printf "%.1fGi/s", v/1048576.0}'
    elif (( kis >= 1024 )); then
      awk -v v="$kis" 'BEGIN{printf "%.1fMi/s", v/1024.0}'
    else
      printf "%dKi/s" "$kis"
    fi
  }
  printf "%s↓ %s↑\n" "$(human "$r_kis")" "$(human "$t_kis")"
fi

