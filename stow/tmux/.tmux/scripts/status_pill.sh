#!/usr/bin/env bash
# Unified status pill for tmux — CPU% · Temp · Load% · Mem% · Net (RX/TX) + E/WiFi state
# Dep-free (prefiere nmcli/iw si existen). Autodetecta interfaces cada vez.
# Autor: Andrés + ChatGPT — 2025-10-13 (robustificado)

# Importante: NO usar "set -e" para no abortar si falta Wi-Fi/NM/sensors.
set -u -o pipefail
export LC_ALL=C

# ---------- Config estética (colores tmux) ----------
GREEN="#[fg=#00ff00]"
AMBER="#[fg=#ffff00]"
RED="#[fg=#ff0000]"
NEUT="#[fg=#cdd6f4]"
RESET="#[fg=#777777]"   # texto base sobre bg de la pastilla

# ---------- Umbrales ----------
cpu_col()  { local v=$1; ((v>=80)) && echo "$RED" || { ((v>=50)) && echo "$AMBER" || echo "$GREEN"; }; }
temp_col() { local v=$1; ((v>=85)) && echo "$RED" || { ((v>=70)) && echo "$AMBER" || echo "$GREEN"; }; }
load_col() { local v=$1; ((v>=100)) && echo "$RED" || { ((v>=70)) && echo "$AMBER" || echo "$GREEN"; }; }
mem_col()  { local v=$1; ((v>=80)) && echo "$RED" || { ((v>=60)) && echo "$AMBER" || echo "$GREEN"; }; }
net_col()  { local mi10=$1; ((mi10>=50*10)) && echo "$RED" || { ((mi10>=10*10)) && echo "$AMBER" || echo "$GREEN"; }; }

# ---------- Helpers ----------
rt_dir() {
  # directorio runtime para estados (mejor que /tmp)
  if [[ -n "${XDG_RUNTIME_DIR:-}" && -w "$XDG_RUNTIME_DIR" ]]; then
    echo "$XDG_RUNTIME_DIR"
  elif [[ -d "/run/user/$(id -u)" && -w "/run/user/$(id -u)" ]]; then
    echo "/run/user/$(id -u)"
  else
    echo "/tmp"
  fi
}

pad_pct() { printf "%3d%%" "$1"; }
fmt_temp(){ printf "%3d°C" "$1"; }

# ---------- CPU % (delta /proc/stat) ----------
cpu_pct() {
  local state_file="$(rt_dir)/tmux_cpu_${USER}.state"
  # campos de /proc/stat línea cpu
  read -r _ u n s i w irq sirq st _ < /proc/stat
  local idle=$(( i + w ))
  local nonidle=$(( u + n + s + irq + sirq + st ))
  local total=$(( idle + nonidle ))

  local prev_total=0 prev_idle=0
  if [[ -f "$state_file" ]]; then
    read -r prev_total prev_idle < "$state_file" || true
  fi
  printf "%s %s\n" "$total" "$idle" > "$state_file"

  local dt=$(( total - prev_total ))
  local didle=$(( idle - prev_idle ))
  if (( dt <= 0 )); then
    echo 0; return
  fi
  awk -v dt="$dt" -v di="$didle" 'BEGIN{printf "%d\n", int(((dt-di)*100.0/dt)+0.5)}'
}

# ---------- Temp (sensors -> sysfs fallback) ----------
cpu_temp_c() {
  if command -v sensors >/dev/null 2>&1; then
    local out
    out=$((sensors 2>/dev/null || true) | awk '
      /Tctl:/ || /Package id 0:/ {
        if (match($0, /\+([0-9]+(\.[0-9])?)°C/, a)) { print a[1]; exit }
      }
      /\+([0-9]+(\.[0-9])?)°C/ {
        if (match($0, /\+([0-9]+(\.[0-9])?)°C/, a)) { print a[1]; exit }
      }')
    if [[ -n "${out:-}" ]]; then
      printf "%d\n" "$(awk -v x="$out" 'BEGIN{printf int(x+0.5)}')"
      return
    fi
  fi
  # sysfs fallback (máxima zona)
  local best=""
  for z in /sys/class/thermal/thermal_zone*/temp; do
    [[ -r "$z" ]] || continue
    local v; v=$(<"$z") || true
    [[ -n "${v:-}" ]] || continue
    local c; c=$(awk -v m="$v" 'BEGIN{printf "%.1f", m/1000.0}')
    if [[ -z "$best" ]]; then best="$c"; else
      best=$(awk -v a="$best" -v b="$c" 'BEGIN{print (b>a?b:a)}')
    fi
  done
  [[ -n "$best" ]] && printf "%d\n" "$(awk -v x="$best" 'BEGIN{printf int(x+0.5)}')" || echo 0
}

# ---------- Load% (L1 / nCPU) ----------
load_pct() {
  read -r L1 _ < <(awk '{print $1}' /proc/loadavg)
  local cpus; cpus=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 1)
  awk -v l1="$L1" -v n="$cpus" 'BEGIN{v=int((l1*100.0/n)+0.5); if(v<0)v=0; if(v>999)v=999; print v}'
}

# ---------- Mem% (MemTotal - MemAvailable) ----------
mem_pct() {
  local total avail used
  total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  avail=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  used=$(( total - avail ))
  awk -v u="$used" -v t="$total" 'BEGIN{printf "%d\n", int((u*100.0/t)+0.5)}'
}

# ---------- Net (autodetect E/W, sumar RX/TX Ki/s, SSID si hay Wi-Fi) ----------
is_wireless_iface() {
  local ifc="$1"
  [[ -e "/sys/class/net/$ifc/wireless" ]] && return 0
  grep -q "^$ifc:" /proc/net/wireless 2>/dev/null && return 0
  return 1
}

nm_ssid_for() {
  local ifc="$1"
  command -v nmcli >/dev/null 2>&1 || { echo ""; return; }
  # Evita abortos si el dispositivo no está gestionado/activo
  local raw ssid
  raw=$(nmcli -t -f GENERAL.DEVICE,GENERAL.TYPE,GENERAL.STATE,GENERAL.CONNECTION dev show "$ifc" 2>/dev/null || true)
  ssid=$(awk -F':' '
    BEGIN{dev="";type="";state="";conn=""}
    /GENERAL.DEVICE:/     {dev=$2}
    /GENERAL.TYPE:/       {type=$2}
    /GENERAL.STATE:/      {state=$2}
    /GENERAL.CONNECTION:/ {conn=$2}
    END{ if(type=="wifi" && state ~ /connected/ && conn!="--") print conn; }' <<<"$raw")
  echo "$ssid"
}

normalize_override_list() {
  local raw="$1" token out=""
  local -A seen=()

  # Normaliza separadores: comas, punto y coma y saltos de línea → espacios
  raw="${raw//$'\n'/ }"
  raw="${raw//,/ }"
  raw="${raw//;/ }"

  for token in $raw; do
    [[ -n "$token" ]] || continue
    [[ -e "/sys/class/net/$token" ]] || continue
    if [[ -z "${seen[$token]:-}" ]]; then
      seen[$token]=1
      out+="$token "
    fi
  done

  [[ -n "$out" ]] && printf '%s' "${out% }"
}

auto_detect_ifaces() {
  local list="" name
  for dev in /sys/class/net/*; do
    name=$(basename "$dev")
    case "$name" in
      lo|veth*|docker*|br-*|vmnet*|tun*|tap*|kube*|virbr*) continue;;
    esac
    [[ -r "$dev/operstate" ]] || continue
    grep -q up "$dev/operstate" || continue
    list+="$name "
  done

  if [[ -z "$list" ]]; then
    local dif
    dif=$(ip -o route show default 2>/dev/null | awk '{print $5; exit}' || true)
    [[ -n "$dif" ]] && list="$dif"
  fi

  [[ -n "$list" ]] && printf '%s' "${list% }"
}

choose_ifaces() {
  # Si el usuario define IF_OVERRIDE="eth0,wlan0", respétalo
  if [[ -n "${IF_OVERRIDE:-}" ]]; then
    local cleaned
    cleaned="$(normalize_override_list "$IF_OVERRIDE")"
    [[ -n "$cleaned" ]] && { echo "$cleaned"; return; }
  fi

  local auto
  auto="$(auto_detect_ifaces)"
  echo "${auto:-}"
}

if [[ "${1:-}" == "--detect-ifaces" ]]; then
  auto_detect_ifaces
  exit 0
fi

net_rates() {
  # Devuelve: "rx_kis tx_kis has_eth has_wifi wifi_ssid"
  local ifaces; ifaces=$(choose_ifaces)
  local rx_sum=0 tx_sum=0
  local has_eth=0 has_wifi=0
  local wifi_name=""

  local now_sec; read -r now_sec _ < /proc/uptime; now_sec=${now_sec%%.*}

  for ifc in $ifaces; do
    local rxf="/sys/class/net/$ifc/statistics/rx_bytes"
    local txf="/sys/class/net/$ifc/statistics/tx_bytes"
    [[ -r "$rxf" && -r "$txf" ]] || continue

    local state_file="$(rt_dir)/tmux_net_${USER}_${ifc}.state"
    local rx; rx=$(<"$rxf")
    local tx; tx=$(<"$txf")

    local prx=0 ptx=0 pts=0 has_prev=0
    if [[ -f "$state_file" ]]; then
      read -r prx ptx pts < "$state_file" 2>/dev/null && has_prev=1 || true
    fi

    local r_kis=0 t_kis=0
    if (( has_prev == 1 )); then
      local dt=$(( now_sec - pts )); (( dt < 1 )) && dt=1
      r_kis=$(awk -v cur="$rx" -v prev="$prx" -v dt="$dt" 'BEGIN{v=(cur-prev)/1024.0/dt; if(v<0)v=0; printf "%d", int(v+0.5)}')
      t_kis=$(awk -v cur="$tx" -v prev="$ptx" -v dt="$dt" 'BEGIN{v=(cur-prev)/1024.0/dt; if(v<0)v=0; printf "%d", int(v+0.5)}')
      rx_sum=$(( rx_sum + r_kis ))
      tx_sum=$(( tx_sum + t_kis ))
    fi

    # Persistir nuevo estado al final
    printf "%s %s %s\n" "$rx" "$tx" "$now_sec" > "$state_file"

    if is_wireless_iface "$ifc"; then
      has_wifi=1
      [[ -z "$wifi_name" ]] && wifi_name="$(nm_ssid_for "$ifc")"
      if [[ -z "$wifi_name" ]] && command -v iw >/dev/null 2>&1; then
        wifi_name="$( (iw dev "$ifc" info 2>/dev/null || true) | awk -F': ' '/ssid/ {print $2; exit}' )"
      fi
    else
      has_eth=1
    fi
  done

  # Si no hay interfaces, devolver ceros
  printf "%d %d %d %d %s\n" "${rx_sum:-0}" "${tx_sum:-0}" "${has_eth:-0}" "${has_wifi:-0}" "${wifi_name// /_}"
}

human_rate_fixed() {
  # entrada: Ki/s; salida: ancho fijo 8 (" 123.4Mi")
  local kis=$1 unit val
  if   (( kis >= 1024*1024 )); then unit="Gi"; val=$(awk -v v="$kis" 'BEGIN{printf "%.1f", v/1048576.0}')
  elif (( kis >= 1024 ));     then unit="Mi"; val=$(awk -v v="$kis" 'BEGIN{printf "%.1f", v/1024.0}')
  else                             unit="Ki"; val=$(awk -v v="$kis" 'BEGIN{printf "%.1f", v+0.0}')
  fi
  printf "%6.1f%2s" "$val" "$unit"
}

# ---------- Métricas ----------
CPU=$(cpu_pct);      CPU_STR=$(pad_pct "$CPU");   CPU_COL=$(cpu_col "$CPU")
TEMP=$(cpu_temp_c);  TEMP_STR=$(fmt_temp "$TEMP");TEMP_COL=$(temp_col "$TEMP")
LOAD=$(load_pct);    LOAD_STR=$(pad_pct "$LOAD"); LOAD_COL=$(load_col "$LOAD")
MEM=$(mem_pct);      MEM_STR=$(pad_pct "$MEM");   MEM_COL=$(mem_col "$MEM")

read -r RX_KIS TX_KIS HAS_ETH HAS_WIFI WIFI_SSID <<<"$(net_rates)"
RX_STR=$(human_rate_fixed "$RX_KIS")
TX_STR=$(human_rate_fixed "$TX_KIS")
# colores net por Mi/s*10 con coma flotante y redondeo
rx_mi10=$(awk -v v_kis="$RX_KIS" 'BEGIN{printf "%d", int((v_kis/1024.0)*10 + 0.5)}')
tx_mi10=$(awk -v v_kis="$TX_KIS" 'BEGIN{printf "%d", int((v_kis/1024.0)*10 + 0.5)}')
RX_COL=$(net_col "$rx_mi10")
TX_COL=$(net_col "$tx_mi10")

# Estado de red compacto
NET_TAG=""
(( HAS_ETH == 1 ))  && NET_TAG+="E"
if (( HAS_WIFI == 1 )); then
  if [[ -n "${WIFI_SSID:-}" && "${WIFI_SSID}" != "--" ]]; then
    [[ -n "$NET_TAG" ]] && NET_TAG+="/"
    NET_TAG+="W:${WIFI_SSID}"
  else
    [[ -n "$NET_TAG" ]] && NET_TAG+="/"
    NET_TAG+="W"
  fi
fi
[[ -n "$NET_TAG" ]] && NET_TAG=" $NEUT[$RESET$NET_TAG$NEUT]$RESET"

# ---------- Salida (una sola línea) ----------
# Icons:  CPU ·  Temp ·  Load ·  Mem ·  Net (↓/↑) + estado E/W
printf "  %s%s%s  %s·%s   %s%s%s  %s·%s   %s%s%s  %s·%s   %s%s%s  %s·%s   %s%s↓%s %s%s↑%s%s " \
  "$CPU_COL"  "$CPU_STR"  "$RESET" \
  "$NEUT" "$RESET" \
  "$TEMP_COL" "$TEMP_STR" "$RESET" \
  "$NEUT" "$RESET" \
  "$LOAD_COL" "$LOAD_STR" "$RESET" \
  "$NEUT" "$RESET" \
  "$MEM_COL"  "$MEM_STR"  "$RESET" \
  "$NEUT" "$RESET" \
  "$RX_COL"  "$RX_STR"  "$RESET" \
  "$TX_COL"  "$TX_STR"  "$RESET" \
  "$NET_TAG"

# Garantiza exit 0 aunque algo falle arriba
exit 0

