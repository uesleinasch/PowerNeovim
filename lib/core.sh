# shellcheck shell=bash
# core.sh — utilities shared by all PowerNeovim modules.

if [[ -t 1 ]]; then
  C_R=$'\033[0m'
  C_B=$'\033[1m'
  C_RED=$'\033[38;5;203m'
  C_GREEN=$'\033[38;5;114m'
  C_YELLOW=$'\033[38;5;215m'
  C_BLUE=$'\033[38;5;110m'
  C_PURPLE=$'\033[38;5;141m'
  C_GRAY=$'\033[38;5;245m'
else
  C_R=""; C_B=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_PURPLE=""; C_GRAY=""
fi

: "${DRY_RUN:=0}"
: "${POWERNEOVIM_NONINTERACTIVE:=0}"
: "${POWERNEOVIM_HOME:=$HOME/PowerNeovim}"

# ---- Logging -----------------------------------------------------------------
log_info()    { printf "%s[powerneovim]%s %s\n" "$C_BLUE" "$C_R" "$*"; }
log_warn()    { printf "%s[powerneovim]%s %s%s%s\n" "$C_YELLOW" "$C_R" "$C_YELLOW" "$*" "$C_R" >&2; }
log_error()   { printf "%s[powerneovim]%s %s%s%s\n" "$C_RED" "$C_R" "$C_RED" "$*" "$C_R" >&2; }
log_success() { printf "%s[powerneovim]%s %s%s%s\n" "$C_GREEN" "$C_R" "$C_GREEN" "$*" "$C_R"; }
log_section() { printf "\n%s%s▸ %s%s\n" "$C_PURPLE" "$C_B" "$*" "$C_R"; }
log_dry()     { printf "%s[dry-run]%s %s\n" "$C_GRAY" "$C_R" "$*"; }

die() { log_error "$*"; exit 1; }

# ---- Predicates --------------------------------------------------------------
has_cmd() { command -v "$1" >/dev/null 2>&1; }

is_supported_distro() {
  [[ -r /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian|pop) return 0 ;;
    *) [[ "${ID_LIKE:-}" =~ (ubuntu|debian) ]] ;;
  esac
}

require_supported_distro() {
  is_supported_distro || die "Distro não suportada. Suporte: Ubuntu, Debian, Pop!_OS."
}

require_not_root() {
  [[ "$(id -u)" -ne 0 ]] || die "Não rode como root. Use seu usuário (sudo é chamado quando necessário)."
}

# ---- Execution wrappers ------------------------------------------------------
# run CMD ARGS… — executes unless DRY_RUN=1, in which case logs the action.
run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "$*"
  else
    "$@"
  fi
}

# as_sudo CMD — runs CMD as root when needed, dry-run aware.
as_sudo() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "sudo $*"
    return 0
  fi
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

# ---- Apt ---------------------------------------------------------------------
apt_install() {
  require_supported_distro
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "apt-get install -y $*"
    return 0
  fi
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

apt_update_once() {
  [[ "${_PN_APT_UPDATED:-}" == "1" ]] && return 0
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "apt-get update"
  else
    sudo env DEBIAN_FRONTEND=noninteractive apt-get update -y
  fi
  _PN_APT_UPDATED=1
}

# ---- Sudo keepalive ----------------------------------------------------------
# Acquires a sudo timestamp now and refreshes it in the background. Required for
# unattended (--yes) runs that take longer than the sudo timestamp_timeout.
setup_sudo_keepalive() {
  [[ "$DRY_RUN" == "1" ]] && return 0
  if ! sudo -n true 2>/dev/null; then
    log_info "sudo: solicitando senha agora (mantida durante todo o install)"
    sudo -v || die "sudo não disponível — abortando."
  fi
  ( while sudo -n true 2>/dev/null && kill -0 "$$" 2>/dev/null; do sleep 50; done ) &
  pn_register_cleanup_pid "$!"
}

# ---- Symlink management ------------------------------------------------------
backup_path() {
  local path="$1"
  [[ -L "$path" ]] && return 0
  if [[ -e "$path" ]]; then
    local bak="${path}.pnbak.$(date +%Y%m%d%H%M%S)"
    log_info "Backup: $path → $bak"
    run mv "$path" "$bak"
  fi
}

# link_safe SRC DST — replace DST with a symlink to SRC, backing up real files.
# Compares the literal symlink target (NOT readlink -f) so dangling links are detected.
link_safe() {
  local src="$1" dst="$2"
  if [[ ! -e "$src" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log_dry "ln -s $src $dst  (source ainda não existe — seria criado por passo anterior)"
      return 0
    fi
    die "link_safe: source não existe: $src"
  fi
  run mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    local cur; cur="$(readlink "$dst" 2>/dev/null || true)"
    if [[ "$cur" == "$src" ]]; then
      log_info "OK (symlink já correto): $dst"
      return 0
    fi
    run rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    backup_path "$dst"
  fi
  log_info "Link: $dst → $src"
  run ln -s "$src" "$dst"
}

# unlink_safe DST — remove DST only if it's a symlink owned by PowerNeovim, then
# restore the most recent backup if one exists.
unlink_safe() {
  local dst="$1"
  if [[ -L "$dst" ]]; then
    local target; target="$(readlink "$dst" 2>/dev/null || true)"
    if [[ "$target" != "$POWERNEOVIM_HOME"/* ]]; then
      log_warn "Symlink $dst não pertence ao PowerNeovim ($target). Ignorado."
      return 0
    fi
    log_info "Removendo symlink: $dst"
    run rm -f "$dst"
  fi
  # Pega o backup mais recente. Sort lexicográfico em sufixo YYYYMMDDHHMMSS é
  # locale-independente e monotônico (resolve ties melhor que `ls -1t`).
  local last_bak
  last_bak="$(ls -1 "${dst}".pnbak.* 2>/dev/null | LC_ALL=C sort -r | head -1 || true)"
  if [[ -n "$last_bak" ]]; then
    log_info "Restaurando backup: $last_bak → $dst"
    run mv "$last_bak" "$dst"
  fi
}

# ---- Filesystem helpers ------------------------------------------------------
ensure_local_bin() { run mkdir -p "$HOME/.local/bin"; }

# download_to URL DST — robust download with retries and timeouts.
download_to() {
  local url="$1" dst="$2"
  log_info "Baixando $url"
  run curl -fL --retry 3 --retry-delay 2 \
    --connect-timeout 15 --max-time 300 \
    -o "$dst" "$url"
}

# install_github_binary URL BIN_NAME — baixa um tar.gz do GitHub que contém um
# binário com o nome BIN_NAME e o instala em ~/.local/bin/BIN_NAME.
# IMPORTANTE: NÃO usa `trap RETURN` porque o trap dispara depois que `local`
# vars saem de escopo, e sob `set -u` isso quebra com "tmp: unbound variable".
install_github_binary() {
  local url="$1" bin="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "install_github_binary $url → ~/.local/bin/$bin"
    return 0
  fi
  local tmp; tmp="$(mktemp -d)"
  download_to "$url" "$tmp/pkg.tar.gz"
  tar -xzf "$tmp/pkg.tar.gz" -C "$tmp"
  # -print -quit evita SIGPIPE no pipe `find | head` sob pipefail (GNU find).
  local found
  found="$(find "$tmp" -maxdepth 3 -type f -name "$bin" -print -quit 2>/dev/null)"
  if [[ -z "$found" ]]; then
    rm -rf "$tmp"
    die "install_github_binary: '$bin' não encontrado em $url"
  fi
  install -m 0755 "$found" "$HOME/.local/bin/$bin"
  rm -rf "$tmp"
}

# clone_or_pull REPO DST [LABEL]
clone_or_pull() {
  local repo="$1" dst="$2" name="${3:-$(basename "$dst")}"
  if [[ -d "$dst/.git" ]]; then
    log_info "Atualizando $name…"
    run git -C "$dst" pull --ff-only \
      || log_warn "$name: pull falhou (mantendo o que existe)"
  elif [[ -d "$dst" ]]; then
    log_warn "$name: diretório existe mas não é git — mantendo."
  else
    log_info "Clonando $name…"
    run git clone --depth=1 "$repo" "$dst"
  fi
}

# curl_pipe URL [ARGS…] — pipes a remote install script through sh, dry-run aware.
curl_pipe() {
  local url="$1"; shift
  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "curl $url | sh -s -- $*"
    return 0
  fi
  curl -fsSL --connect-timeout 15 --max-time 300 "$url" | sh -s -- "$@"
}

# ---- Post-install notes ------------------------------------------------------
# Permite que módulos enfileirem tarefas manuais (ex.: chsh) que não conseguiram
# completar sozinhos. Usamos arquivo (não array) porque os módulos rodam em
# subshell — array em pai não receberia as escritas do filho.
: "${POWERNEOVIM_NOTES_FILE:=}"
if [[ -z "$POWERNEOVIM_NOTES_FILE" ]]; then
  POWERNEOVIM_NOTES_FILE="$(mktemp -t powerneovim-notes.XXXXXX 2>/dev/null || mktemp)"
  export POWERNEOVIM_NOTES_FILE
fi

post_install_note() {
  printf '%s\n' "$*" >> "$POWERNEOVIM_NOTES_FILE"
}

print_post_install_notes() {
  [[ -f "$POWERNEOVIM_NOTES_FILE" && -s "$POWERNEOVIM_NOTES_FILE" ]] || return 0
  log_section "Tarefas manuais necessárias"
  local i=1
  while IFS= read -r note; do
    [[ -z "$note" ]] && continue
    printf "  %s%d)%s %s\n" "$C_YELLOW" "$i" "$C_R" "$note"
    i=$((i+1))
  done < "$POWERNEOVIM_NOTES_FILE"
}

# ---- Cleanup orquestrado -----------------------------------------------------
# Trap único de EXIT (a setup_sudo_keepalive registra dentro deste contrato).
_PN_CLEANUP_PIDS=()
pn_register_cleanup_pid() { _PN_CLEANUP_PIDS+=("$1"); }

pn_cleanup() {
  local pid
  for pid in "${_PN_CLEANUP_PIDS[@]:-}"; do
    [[ -n "${pid:-}" ]] && kill "$pid" 2>/dev/null || true
  done
  [[ -f "${POWERNEOVIM_NOTES_FILE:-}" ]] && rm -f "$POWERNEOVIM_NOTES_FILE" 2>/dev/null || true
}

# ---- Status helpers ----------------------------------------------------------
status_line() {
  local ok="$1" label="$2"
  if [[ "$ok" == "1" ]]; then
    printf "  %s✓%s %s\n" "$C_GREEN" "$C_R" "$label"
  else
    printf "  %s✗%s %s\n" "$C_RED" "$C_R" "$label"
  fi
}
