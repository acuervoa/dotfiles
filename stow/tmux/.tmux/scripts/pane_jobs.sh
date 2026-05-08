#!/usr/bin/env bash
# Uso: pane_jobs.sh <pane_pid>
ROOT="$1"
[[ -z "$ROOT" ]] && { echo "0"; exit 0; }

# Single ps call — no recursive subprocess spawning
ps -eo pid=,ppid=,comm= 2>/dev/null | awk -v root="$ROOT" '
{
  pid[NR]=$1; ppid[NR]=$2; comm[NR]=$3
}
END {
  n=NR
  # BFS from root
  split("", queue); split("", visited)
  qhead=1; qtail=1
  queue[qtail++]=root
  count=0
  while (qhead < qtail) {
    p=queue[qhead++]
    for (i=1; i<=n; i++) {
      if (ppid[i]==p && !visited[pid[i]]) {
        visited[pid[i]]=1
        c=comm[i]
        if (c!="bash" && c!="zsh" && c!="fish" && c!="tmux" && c!="sh")
          count++
        queue[qtail++]=pid[i]
      }
    }
  }
  print count
}
'
