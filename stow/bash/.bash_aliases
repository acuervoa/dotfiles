# ~/.bash_aliases - alias productivos y seguros

# Atajos de calidad de vida
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status -sb 2>/dev/null || git status'
alias gst='git status'
alias gc='git commit'
alias gcm='git commit -m'
alias gup='git pull --rebase --autostash'
alias gfa='git fetch --all --prune'
alias gpf='git push --force-with-lease'
alias gl='git log --oneline --graph -n 30'
alias gd='git diff --color=always | bat --paging=always --plain --color=always 2>/dev/null || git diff'
alias gds='git diff --cached --color=always | bat --paging=always --plain --color=always 2>/dev/null || git diff --cached'
alias ga='git add -A'
alias gco='git checkout'
alias gcob="git checkout -b"
alias gsw='git switch'
if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi

# ls mejorado: eza
alias l='\ls --color=auto'
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto --color=auto --sort newest -la'
  alias ll='eza -lh --git --group-directories-first --icons=auto --color=auto --sort newest'
  alias la='eza -a --group-directories-first --icons=auto --color=auto --sort newest'
else
  alias ls='ls --color=auto'
  alias ll='ls -alh --color=auto'
  alias la='ls -A --color=auto'
fi

# Docker compose V2
if command -v docker >/dev/null 2>&1; then
  alias dc='docker compose'
  alias dcb='docker compose build'
  alias dcp='docker compose pull'
  alias dcu='docker compose up'
  alias dcud='docker compose up -d'
  alias dcd='docker compose down'
  alias dcr='docker compose restart'
  alias dcrb='docker compose build --no-cache && docker compose up -d'
  alias dps='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
  alias dil='docker images'
  # dsh directo a php (tu servicio principal)
  alias dshp='dsh php'
fi

# Modernos y seguros
if command -v bat >/dev/null 2>&1; then
  alias cat="bat -p --paging=never"
fi
alias grep="grep --color=auto"
alias rgrep="rg --color=auto"
if command -v nvim >/dev/null 2>&1; then
  alias vim="nvim"
  alias n="nvim"
fi

# Atajos útiles
alias cls="clear"
alias reload="source ~/.bashrc"
alias path='echo "$PATH" | tr ":" "\n"'

# tldr - simplified man pages (install: brew install tldr or sudo pacman -S tldr)
if command -v tldr >/dev/null 2>&1; then
  alias tldr="tldr"
fi
# PHP shortcuts (docker compose exec php)
if command -v docker >/dev/null 2>&1 && docker compose ps php >/dev/null 2>&1; then
  alias p='docker compose exec php php'
  alias part='docker compose exec php php artisan'
  alias ptest='docker compose exec php php vendor/bin/phpunit'
  alias pstan='docker compose exec php php vendor/bin/phpstan'
  alias pint='docker compose exec php ./vendor/bin/pint'
  alias pcc='docker compose exec php php artisan cache:clear'
  alias pmig='docker compose exec php php artisan migrate'
  alias pseed='docker compose exec php php artisan db:seed'
  alias pcf='docker compose exec php php artisan config:cache'
  alias proute='docker compose exec php php artisan route:list'
  alias pclear='docker compose exec php php artisan view:clear && docker compose exec php php artisan cache:clear && docker compose exec php php artisan config:clear'
fi
