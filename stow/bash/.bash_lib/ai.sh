#!/usr/bin/env bash
# ai.sh - Aliases y helpers para el flujo de trabajo con IA (SimpleBrain)

# --- 🚀 SESIONES RÁPIDAS (SimpleBrain) ---

_sb_session_state_dir="$HOME/.cache/simplebrain-ai"
_sb_session_state_file="$_sb_session_state_dir/last-session"

_sb_read_state_value() {
  local key="$1"
  [[ -f "$_sb_session_state_file" ]] || return 1
  grep -E "^${key}=" "$_sb_session_state_file" | head -n 1 | cut -d= -f2-
}

_sb_brief_task() {
  local brief_path="$1"
  [[ -n "${brief_path:-}" && -f "$brief_path" ]] || return 1
  grep -E '^- Tarea:' "$brief_path" | head -n 1 | cut -d: -f2- | xargs
}

_sb_sanitize_task_for_note() {
  python3 - <<'PY' "$1"
import re, sys
text = sys.argv[1]
clean = re.sub(r'[<>:"/\\|?*\x00-\x1f]', '', text)
clean = re.sub(r'\s+', ' ', clean).strip()
print(clean[:60])
PY
}

_sb_project_note_path() {
  local task="$1"
  local name
  name="$(_sb_sanitize_task_for_note "$task")" || return 1
  printf '%s\n' "$HOME/Vaults/SimpleBrain/02_PROJECTS/P - ${name}.md"
}

_sb_today_daily_path() {
  printf '%s\n' "$HOME/Vaults/SimpleBrain/DAILY/$(date +%Y-%m-%d).md"
}

_sb_open_sessions_archive_dir() {
  printf '%s\n' "$HOME/Vaults/SimpleBrain/99_META/ai-contexts/_orphaned-starts"
}

sbo() {
  local vault_root
  vault_root="$HOME/Vaults/SimpleBrain"
  python3 - <<'PY' "$vault_root" "$_sb_session_state_file"
import re, sys
from collections import defaultdict, deque
from pathlib import Path

vault_root = Path(sys.argv[1])
state_file = Path(sys.argv[2])
ctx = vault_root / "99_META" / "ai-contexts"

def extract_task(path: Path) -> str | None:
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    m = re.search(r"^- Tarea:\s*(.+)$", text, re.M)
    return m.group(1).strip() if m else None

def extract_state_value(key: str) -> str | None:
    if not state_file.exists():
        return None
    for line in state_file.read_text(encoding="utf-8").splitlines():
        if line.startswith(f"{key}="):
            return line.split("=", 1)[1]
    return None

starts = []
for path in sorted(ctx.glob("*__ai-start.md")):
    task = extract_task(path)
    starts.append((path, task))

handoffs_by_task = defaultdict(deque)
for path in sorted(ctx.glob("*__ai-handoff.md")):
    task = extract_task(path)
    if task:
        handoffs_by_task[task].append(path)

open_candidates = []
for path, task in starts:
    if not task:
        continue
    queue = handoffs_by_task[task]
    if queue:
        queue.popleft()
    else:
        open_candidates.append((path, task))

active_task = extract_state_value("task")
active_brief = extract_state_value("brief")

if active_task:
    print("Sesión activa registrada:")
    print(f"- Tarea: {active_task}")
    if active_brief:
        print(f"- Brief: {active_brief}")
else:
    print("Sesión activa registrada: ninguna")

print("")
if not open_candidates:
    print("Sesiones candidatas a abiertas: ninguna")
    raise SystemExit(0)

print("Sesiones candidatas a abiertas (arrancadas sin handoff emparejado):")
for path, task in open_candidates:
    print(f"- {path.name} | {task}")
PY
}
_sb_write_session_state() {
  local task="$1"
  local started_at="$2"
  local brief="$3"
  local note="${4:-}"

  if ! {
    printf 'task=%s\n' "$task"
    printf 'started_at=%s\n' "$started_at"
    printf 'brief=%s\n' "$brief"
    [[ -n "$note" ]] && printf 'note=%s\n' "$note"
  } | tee "$_sb_session_state_file" >/dev/null 2>&1; then
    printf 'Error: no pude guardar el estado de la sesión en %s\n' "$_sb_session_state_file" >&2
    return 1
  fi
}

_sb_require_active_session() {
  local task brief brief_task

  if [[ ! -f "$_sb_session_state_file" ]]; then
    printf 'Error: no hay sesión activa. Ejecuta sbs "<tarea>" antes de cerrar.\n' >&2
    return 1
  fi

  task="$(_sb_read_state_value task)"
  brief="$(_sb_read_state_value brief)"

  if [[ -z "${task:-}" ]]; then
    printf 'Error: last-session no contiene task=. Refuerza la sesión con sbs "<tarea>".\n' >&2
    return 1
  fi

  if [[ -n "${brief:-}" ]]; then
    if [[ ! -f "$brief" ]]; then
      printf 'Error: el brief guardado ya no existe: %s\n' "$brief" >&2
      return 1
    fi
    brief_task="$(_sb_brief_task "$brief")"
    if [[ -z "${brief_task:-}" ]]; then
      printf 'Error: no pude leer la tarea del brief guardado: %s\n' "$brief" >&2
      return 1
    fi
    if [[ "$brief_task" != "$task" ]]; then
      printf 'Error: last-session y brief no coinciden. task="%s" brief="%s"\n' "$task" "$brief_task" >&2
      return 1
    fi
  fi

  printf '%s\n' "$task"
}

# sbs: Start Brain Session
# Uso: sbs "Tarea a realizar"
sbs() {
  local note=""
  if [[ "${1:-}" == "--note" ]]; then
    note="$2"
    shift 2
  fi
  if [[ -z "$*" ]]; then
    printf "Uso: sbs [--note <ruta-nota>] <descripción de la tarea>\n"
    return 1
  fi
  # Resolve note: vault-relative → absolute
  if [[ -n "$note" && "$note" != /* ]]; then
    note="$HOME/Vaults/SimpleBrain/$note"
  fi
  if [[ -f "$_sb_session_state_file" ]]; then
    local _active_task _active_note
    _active_task="$(_sb_read_state_value task)"
    if [[ -n "$_active_task" ]]; then
      _active_note="$(_sb_read_state_value note)"
      [[ -z "$_active_note" ]] && _active_note="$(_sb_project_note_path "$_active_task")"
      printf 'Error: ya hay una sesión activa.\n' >&2
      printf '  Tarea: %s\n' "$_active_task" >&2
      printf '  Nota:  %s\n' "$_active_note" >&2
      printf 'Ciérrala con: sbe "<hecho>"\n' >&2
      return 1
    fi
  fi
  mkdir -p "$_sb_session_state_dir"
  local brief
  local started_at
  local start_ms
  local total_ms
  start_ms=$(date +%s%3N)
  started_at=$(date +%Y-%m-%dT%H:%M:%S)
  printf 'Iniciando sesión y generando brief: %s\n' "$*"
  local ai_args=(--task "$*" --copy)
  [[ -n "$note" ]] && ai_args+=(--project-note "$note")
  if ! brief=$(AI_SESSION_BENCH=${AI_SESSION_BENCH:-0} ai-session start "${ai_args[@]}"); then
    printf 'Error: ai-session start falló para la tarea: %s\n' "$*" >&2
    return 1
  fi
  printf '%s\n' "$brief"
  if ! _sb_write_session_state "$*" "$started_at" "$brief" "$note"; then
    printf 'Error: el brief se generó, pero la sesión no quedó registrada. Revisa permisos en %s\n' "$_sb_session_state_dir" >&2
    return 1
  fi
  if [[ "${AI_SESSION_BENCH:-0}" == "1" ]]; then
    total_ms=$(( $(date +%s%3N) - start_ms ))
    printf '[sbs][bench] phase=total elapsed_ms=%s\n' "$total_ms" >&2
  fi
}

# sbsb: Start Brain Session con benchmark
# Uso: sbsb "Tarea a realizar"
sbsb() {
  if [[ -z "$*" ]]; then
    printf "Uso: sbsb <descripción de la tarea>\n"
    return 1
  fi
  AI_SESSION_BENCH=1 sbs "$@"
}

# sbl: Start Brain Session & Launch Agent
# Uso: sbl "Tarea a realizar" (abre Claude/Codex automáticamente)
sbl() {
  local note=""
  if [[ "${1:-}" == "--note" ]]; then
    note="$2"
    shift 2
  fi
  if [[ -z "$*" ]]; then
    printf "Uso: sbl [--note <ruta-nota>] <descripción de la tarea>\n"
    return 1
  fi
  if [[ -n "$note" && "$note" != /* ]]; then
    note="$HOME/Vaults/SimpleBrain/$note"
  fi
  if [[ -f "$_sb_session_state_file" ]]; then
    local _active_task _active_note
    _active_task="$(_sb_read_state_value task)"
    if [[ -n "$_active_task" ]]; then
      _active_note="$(_sb_read_state_value note)"
      [[ -z "$_active_note" ]] && _active_note="$(_sb_project_note_path "$_active_task")"
      printf 'Error: ya hay una sesión activa.\n' >&2
      printf '  Tarea: %s\n' "$_active_task" >&2
      printf '  Nota:  %s\n' "$_active_note" >&2
      printf 'Ciérrala con: sbe "<hecho>"\n' >&2
      return 1
    fi
  fi
  mkdir -p "$_sb_session_state_dir"
  local brief
  local started_at
  local start_ms
  local total_ms
  start_ms=$(date +%s%3N)
  started_at=$(date +%Y-%m-%dT%H:%M:%S)
  printf 'Iniciando sesión, generando brief y lanzando agente: %s\n' "$*"
  local ai_args=(--task "$*" --copy --launch)
  [[ -n "$note" ]] && ai_args+=(--project-note "$note")
  if ! brief=$(AI_SESSION_BENCH=${AI_SESSION_BENCH:-0} ai-session start "${ai_args[@]}"); then
    printf 'Error: ai-session start --launch falló para la tarea: %s\n' "$*" >&2
    return 1
  fi
  printf '%s\n' "$brief"
  if ! _sb_write_session_state "$*" "$started_at" "$brief" "$note"; then
    printf 'Error: el brief se generó, pero la sesión no quedó registrada. Revisa permisos en %s\n' "$_sb_session_state_dir" >&2
    return 1
  fi
  if [[ "${AI_SESSION_BENCH:-0}" == "1" ]]; then
    total_ms=$(( $(date +%s%3N) - start_ms ))
    printf '[sbl][bench] phase=total elapsed_ms=%s\n' "$total_ms" >&2
  fi
}

# sbe: End Brain Session (Documenta en Diario + Proyecto)
# Uso: sbe "Lo que hice" ["Siguiente paso"]
sbe() {
  local task
  local done_summary
  local next_step
  local handoff
  local project_note
  local daily_note

  if [[ -z "${1:-}" ]]; then
    printf "Uso: sbe <hecho> [siguiente paso]\n" >&2
    return 1
  fi

  done_summary="$1"
  next_step="${2:-}"

  printf 'Buscando sesión activa para cerrar...\n'
  task="$(_sb_require_active_session)" || return 1
  local stored_note
  stored_note="$(_sb_read_state_value note)"
  if [[ -n "$stored_note" ]]; then
    project_note="$stored_note"
  else
    project_note="$(_sb_project_note_path "$task")"
  fi
  daily_note="$(_sb_today_daily_path)"

  printf 'Sesión activa encontrada: %s\n' "$task"
  printf 'Nota de proyecto: %s\n' "$project_note"
  printf 'Resumen de cierre:\n'
  printf '  - Hecho: %s\n' "$done_summary"
  if [[ -n "$next_step" ]]; then
    printf '  - Próximo: %s\n' "$next_step"
  else
    printf '  - Próximo: lo inferirá ai-session a partir del cierre\n'
  fi
  printf 'Generando handoff y actualizando proyecto/daily...\n'

  local note_args=()
  [[ -n "$stored_note" ]] && note_args+=(--project-note "$stored_note")

  if [[ -n "$next_step" ]]; then
    if ! handoff=$(ai-session end --task "$task" --done "$done_summary" --next "$next_step" --daily --update-project-note "${note_args[@]}" --copy); then
      printf 'Error: no pude cerrar la sesión activa: %s\n' "$task" >&2
      return 1
    fi
  else
    if ! handoff=$(ai-session end --task "$task" --done "$done_summary" --daily --update-project-note "${note_args[@]}" --copy); then
      printf 'Error: no pude cerrar la sesión activa: %s\n' "$task" >&2
      return 1
    fi
  fi

  printf 'Handoff generado: %s\n' "$handoff"
  printf 'Proyecto actualizado: %s\n' "$project_note"
  printf 'Daily actualizada: %s\n' "$daily_note"
  if ! rm -f "$_sb_session_state_file"; then
    printf 'Warning: no pude borrar el estado de sesión en %s\n' "$_sb_session_state_file" >&2
    return 1
  fi
  printf 'Estado de sesión limpiado: %s\n' "$_sb_session_state_file"
  printf 'Sesión cerrada correctamente.\n'
}
_sb_stale_sessions_archive_dir() {
  printf '%s\n' "$HOME/Vaults/SimpleBrain/99_META/ai-contexts/_stale-open-starts"
}

sbo-clean() {
  local mode
  local vault_root
  local archive_dir
  mode="preview"
  if [[ "${1:-}" == "--apply" ]]; then
    mode="apply"
  elif [[ -n "${1:-}" ]]; then
    printf "Uso: sbo-clean [--apply]\n" >&2
    return 1
  fi
  vault_root="$HOME/Vaults/SimpleBrain"
  archive_dir="$(_sb_open_sessions_archive_dir)"
  python3 - <<'PY' "$vault_root" "$archive_dir" "$mode"
import re, sys, shutil
from collections import defaultdict, deque
from pathlib import Path

vault_root = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
mode = sys.argv[3]
ctx = vault_root / "99_META" / "ai-contexts"
archive_dir.mkdir(parents=True, exist_ok=True)

TEST_PATTERNS = [
    r"\bprueba\b",
    r"\btest\b",
    r"\btrace\b",
    r"\bbench\b",
    r"\bcolgado\b",
    r"\bvelocidad\b",
    r"\bsymlink\b",
]

def extract_task(path: Path) -> str | None:
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    m = re.search(r"^- Tarea:\s*(.+)$", text, re.M)
    return m.group(1).strip() if m else None

def is_test_task(task: str) -> bool:
    lowered = task.lower()
    return any(re.search(pattern, lowered) for pattern in TEST_PATTERNS)

starts = []
for path in sorted(ctx.glob("*__ai-start.md")):
    task = extract_task(path)
    starts.append((path, task))

handoffs_by_task = defaultdict(deque)
for path in sorted(ctx.glob("*__ai-handoff.md")):
    task = extract_task(path)
    if task:
        handoffs_by_task[task].append(path)

open_candidates = []
for path, task in starts:
    if not task:
        continue
    queue = handoffs_by_task[task]
    if queue:
        queue.popleft()
    else:
        open_candidates.append((path, task))

to_archive = [(path, task) for path, task in open_candidates if is_test_task(task)]

if not to_archive:
    print("No hay sesiones candidatas de prueba para archivar.")
    raise SystemExit(0)

if mode == "preview":
    print("Sesiones candidatas de prueba para archivar:")
    for path, task in to_archive:
        print(f"- {path.name} | {task}")
    print("")
    print(f"Ejecuta: sbo-clean --apply")
    raise SystemExit(0)

archived = []
for path, task in to_archive:
    dest = archive_dir / path.name
    shutil.move(str(path), str(dest))
    archived.append((dest, task))

print("Sesiones archivadas:")
for dest, task in archived:
    print(f"- {dest.name} | {task}")
print(f"Total archivadas: {len(archived)}")
PY
}

sbclose() {
  local task
  local reason
  local project_note

  if [[ -z "${1:-}" ]]; then
    printf "Uso: sbclose <tarea> [motivo]\n" >&2
    return 1
  fi

  task="$1"
  reason="${2:-Proyecto cerrado explícitamente.}"

  if [[ -f "$_sb_session_state_file" ]]; then
    local active_task
    active_task="$(_sb_read_state_value task)"
    if [[ -n "$active_task" ]]; then
      if [[ "$active_task" == "$task" ]]; then
        printf 'Sesión activa detectada para "%s". Cerrando con sbe antes de sbclose...\n' "$task"
        sbe "$reason" || return 1
      else
        printf 'Error: sesión activa para otra tarea: "%s". Cierra con sbe antes de sbclose.\n' "$active_task" >&2
        return 1
      fi
    fi
  fi

  project_note="$(_sb_project_note_path "$task")"

  if [[ ! -f "$project_note" ]]; then
    printf 'Error: no existe la nota de proyecto: %s\n' "$project_note" >&2
    return 1
  fi

  python3 - <<'PY' "$project_note" "$reason" "$HOME/Vaults/SimpleBrain"
import re, sys
from datetime import datetime
from pathlib import Path

project_note = Path(sys.argv[1])
reason = sys.argv[2].strip() or "Proyecto cerrado explícitamente."
vault_root = Path(sys.argv[3])
today = datetime.now().strftime("%Y-%m-%d")
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
time_only = datetime.now().strftime("%H:%M")
text = project_note.read_text(encoding="utf-8")

def update_frontmatter(text: str) -> str:
    if not text.startswith("---\n"):
        return text
    parts = text.split("---\n", 2)
    if len(parts) < 3:
        return text
    frontmatter, body = parts[1], parts[2]
    if re.search(r"^status:\s*.*$", frontmatter, flags=re.M):
        frontmatter = re.sub(r"^status:\s*.*$", "status: completed", frontmatter, flags=re.M)
    else:
        frontmatter = frontmatter.rstrip() + "\nstatus: completed\n"
    if re.search(r"^updated:\s*.*$", frontmatter, flags=re.M):
        frontmatter = re.sub(r"^updated:\s*.*$", f"updated: {today}", frontmatter, flags=re.M)
    else:
        frontmatter = frontmatter.rstrip() + f"\nupdated: {today}\n"
    return f"---\n{frontmatter}---\n{body}"

text = update_frontmatter(text)
lines = text.splitlines()
for idx, line in enumerate(lines):
    if re.match(r"^\s*[-*]\s+\[ \]\s+.*#next\b", line):
        line = re.sub(r"^(\s*[-*]\s+\[)\s(\]\s+)", r"\1x\2", line, count=1)
        line = re.sub(r"#next\b", "#done", line)
        lines[idx] = line
text = "\n".join(lines).rstrip() + "\n"

heading = "## Siguiente paso sugerido"
replacement = f"{heading}\n- Proyecto cerrado explícitamente."
pattern = re.compile(rf"(?ms)^{re.escape(heading)}\n.*?(?=^## |\Z)")
if pattern.search(text):
    text = pattern.sub(replacement, text, count=1)
else:
    text = text.rstrip() + f"\n\n{replacement}\n"

close_heading = "## Cierre"
close_block = f"{close_heading}\n- Cerrado explícitamente: {timestamp}\n- Motivo: {reason}"
close_pattern = re.compile(rf"(?ms)^{re.escape(close_heading)}\n.*?(?=^## |\Z)")
if close_pattern.search(text):
    text = close_pattern.sub(close_block, text, count=1)
else:
    text = text.rstrip() + f"\n\n{close_block}\n"

project_note.write_text(text, encoding="utf-8")

# Registrar cierre en la nota DAILY de hoy
task_name = project_note.stem.removeprefix("P - ")
daily_note = vault_root / "DAILY" / f"{today}.md"
CLOSED_SECTION = "## ✅ Proyectos Cerrados"
entry = f"- [{time_only}] **{task_name}** — {reason}"
if daily_note.exists():
    daily_content = daily_note.read_text(encoding="utf-8")
    if CLOSED_SECTION in daily_content:
        daily_content = daily_content.replace(
            CLOSED_SECTION,
            f"{CLOSED_SECTION}\n{entry}",
            1,
        )
    else:
        daily_content = daily_content.rstrip() + f"\n\n{CLOSED_SECTION}\n{entry}\n"
    daily_note.write_text(daily_content, encoding="utf-8")
    print(f"📝 Daily actualizada: DAILY/{today}.md", file=sys.stderr)

print(project_note)
PY
  printf "Proyecto cerrado: %s\n" "$project_note"
  printf "Motivo: %s\n" "$reason"
}

sbo-archive-stale() {
  local mode
  local vault_root
  local archive_dir
  mode="preview"
  if [[ "${1:-}" == "--apply" ]]; then
    mode="apply"
  elif [[ -n "${1:-}" ]]; then
    printf "Uso: sbo-archive-stale [--apply]\n" >&2
    return 1
  fi
  vault_root="$HOME/Vaults/SimpleBrain"
  archive_dir="$(_sb_stale_sessions_archive_dir)"
  python3 - "$vault_root" "$archive_dir" "$mode" <<'PY'
import re, sys, shutil
from collections import defaultdict, deque
from pathlib import Path

vault_root = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
mode = sys.argv[3]
ctx = vault_root / "99_META" / "ai-contexts"
projects = vault_root / "02_PROJECTS"
archive_dir.mkdir(parents=True, exist_ok=True)

STALE_STATUSES = {"done", "completed", "paused"}

def extract_task(path: Path) -> str | None:
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    m = re.search(r"^- Tarea:\s*(.+)$", text, re.M)
    return m.group(1).strip() if m else None

def sanitize(text: str) -> str:
    clean = re.sub(r'[<>:"/\\|?*\x00-\x1f]', '', text)
    clean = re.sub(r"\s+", " ", clean).strip()
    return clean[:60]

def note_status(task: str) -> tuple[str | None, Path | None]:
    note = projects / f"P - {sanitize(task)}.md"
    if not note.exists():
        return None, None
    text = note.read_text(encoding="utf-8")
    m = re.search(r"^status:\s*(.+)$", text, re.M)
    return (m.group(1).strip() if m else None), note

starts = []
for path in sorted(ctx.glob("*__ai-start.md")):
    task = extract_task(path)
    if task:
        starts.append((path, task))

handoffs_by_task = defaultdict(deque)
for path in sorted(ctx.glob("*__ai-handoff.md")):
    task = extract_task(path)
    if task:
        handoffs_by_task[task].append(path)

open_candidates = []
for path, task in starts:
    queue = handoffs_by_task[task]
    if queue:
        queue.popleft()
    else:
        open_candidates.append((path, task))

to_archive = []
for path, task in open_candidates:
    status, note = note_status(task)
    if status in STALE_STATUSES:
        to_archive.append((path, task, status, note))

if not to_archive:
    print("No hay sesiones huérfanas stale para archivar.")
    raise SystemExit(0)

if mode == "preview":
    print("Sesiones huérfanas stale para archivar:")
    for path, task, status, note in to_archive:
        note_name = note.name if note else "-"
        print(f"- {path.name} | {task} | status={status} | note={note_name}")
    print("")
    print("Ejecuta: sbo-archive-stale --apply")
    raise SystemExit(0)

archived = []
for path, task, status, note in to_archive:
    dest = archive_dir / path.name
    shutil.move(str(path), str(dest))
    archived.append((dest, task, status, note))

print("Sesiones stale archivadas:")
for dest, task, status, note in archived:
    note_name = note.name if note else "-"
    print(f"- {dest.name} | {task} | status={status} | note={note_name}")
print(f"Total archivadas: {len(archived)}")
PY
}
# sb-lint: Ejecuta auditoría rápida del Vault
alias sb-lint='python3 ~/Vaults/SimpleBrain/tools/audit_frontmatter.py --wiki-only'

# --- 🧪 FLUJO AI-FLOW (Avanzado) ---

alias afs='ai-flow start'
alias afc='ai-flow cycle'
alias afd='ai-flow distill-run'
alias afa='ai-flow distill-apply'

# --- ⚗️ DISTILLATION (Conocimiento Durable) ---

# aflast: Localiza el último draft de destilación generado
aflastdraft() {
  ls -1t "$HOME/Vaults/SimpleBrain/99_META/distill-logs/"*__ai-distill-draft.md 2>/dev/null | head -n 1
}

# afapply: Aplica el último draft al wiki
afapplylast() {
  local draft
  draft="$(aflastdraft)"
  if [[ -z "$draft" ]]; then
    printf 'No encontré drafts de distill.\n' >&2
    return 1
  fi
  ai-flow distill-apply --draft "$draft" --apply-note --apply-wiki-log
}

# --- 🖥️ UTILIDADES Y AGENTES ---

# ia: Abre el entorno tmux para trabajo con IA
ia() {
  local session_bin="$HOME/.local/bin/ia-session"
  if [[ ! -x "$session_bin" ]]; then
    printf 'No existe o no es ejecutable: %s\n' "$session_bin" >&2
    return 1
  fi
  "$session_bin" "$@"
}

# gpt: Abre la webapp de ChatGPT
gpt() {
  if ! command -v gtk-launch >/dev/null 2>&1; then
    printf 'gtk-launch no está disponible.\n' >&2
    return 1
  fi
  gtk-launch chatgpt-webapp "$@"
}

# gpt-safe: Abre ChatGPT sin aceleración GPU (para evitar cuelgues)
gpt-safe() {
  CHATGPT_WEBAPP_DISABLE_GPU=1 gpt "$@"
}

# Codex/Agent alias rápido
alias codex-here='codex'

# sbprofile: copia about-me.compact.md al portapapeles para pegar en cualquier LLM
sbprofile() {
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  local _profile="$_sb_vault/04_RESOURCES/about-me.compact.md"
  if [[ ! -f "$_profile" ]]; then
    printf 'Error: no encontrado %s\n' "$_profile" >&2
    return 1
  fi
  cb "$_profile" && printf 'Perfil copiado al portapapeles. Pega al inicio del chat.\n'
}
# ai: bootstrap AI session from current repo (v0.1)
# ai [start] "task"  → detects git root, generates brief, opens project note
# ai end/distill ... → delegates to ai-session
ai() {
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  local _ai_wrapper="$_sb_vault/tools/ai"
  local subcmd="${1:-}"
  if [[ "$subcmd" == "end" || "$subcmd" == "distill" ]]; then
    ai-session "$@"
  elif [[ -x "$_ai_wrapper" ]]; then
    "$_ai_wrapper" "$@"
  else
    printf 'Error: no se encontró %s\n' "$_ai_wrapper" >&2
    return 1
  fi
}
