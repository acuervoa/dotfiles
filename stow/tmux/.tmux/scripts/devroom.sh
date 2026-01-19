#!/usr/bin/env bash
# Development War Room en tmux

SESSION="devroom"

# Crear sesión si no existe
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
  tmux new-session -d -s $SESSION -n dev

  # Pane 1: Git
  tmux send-keys -t $SESSION 'lazygit' C-m

  # Pane 2: Tests automáticos
  tmux split-window -h -t $SESSION
  tmux send-keys -t $SESSION 'watchexec -e php "vendor/bin/phpunit"' C-m

  # Pane 3: Servidor/API local
  tmux split-window -v -t $SESSION:.0
  tmux send-keys -t $SESSION 'php -S 0.0.0.0:8080 -t public' C-m

  # Pane 4: API testing (xh)
  tmux split-window -v -t $SESSION:.1
  tmux send-keys -t $SESSION 'xh :8080/health' C-m

  # Pane 5: Logs de aplicación
  tmux split-window -h -t $SESSION:.2
  tmux send-keys -t $SESSION 'tail -f storage/logs/laravel.log' C-m

  # Layout en mosaico
  tmux select-layout -t $SESSION tiled
fi

tmux attach -t $SESSION

