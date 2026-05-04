# shellcheck shell=bash
# ui.sh — TUI helpers (whiptail with text-mode fallback).

ui_has_whiptail() { has_cmd whiptail; }

# ui_select_modules — prints the chosen modules separated by spaces on stdout.
# Uses whiptail when available, falls back to a numbered text menu.
# Args: list of "<id>:<description>" pairs.
ui_select_modules() {
  local pairs=("$@")
  if ui_has_whiptail; then
    local args=()
    local id desc
    for p in "${pairs[@]}"; do
      id="${p%%:*}"
      desc="${p#*:}"
      args+=("$id" "$desc" "ON")
    done
    local result
    result="$(whiptail --title "PowerNeovim — selecione os módulos" \
      --checklist "Use SPACE para alternar, ENTER para confirmar." \
      20 78 12 "${args[@]}" 3>&1 1>&2 2>&3)" || return 1
    # whiptail returns "id1" "id2" "id3" with quotes
    echo "$result" | tr -d '"'
    return 0
  fi
  # Fallback: text menu
  printf "\nMódulos disponíveis (todos selecionados por default):\n" >&2
  local i=1
  for p in "${pairs[@]}"; do
    printf "  %d) %-12s %s\n" "$i" "${p%%:*}" "${p#*:}" >&2
    i=$((i+1))
  done
  printf "\nDigite os números separados por espaço (ENTER = todos): " >&2
  local input; read -r input
  if [[ -z "$input" ]]; then
    local out=()
    for p in "${pairs[@]}"; do out+=("${p%%:*}"); done
    echo "${out[@]}"
    return 0
  fi
  local out=()
  for n in $input; do
    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#pairs[@]} )); then
      out+=("${pairs[$((n-1))]%%:*}")
    fi
  done
  echo "${out[@]}"
}

ui_confirm() {
  local msg="$1"
  if [[ "${POWERNEOVIM_NONINTERACTIVE:-0}" == "1" ]]; then
    return 0
  fi
  if ui_has_whiptail; then
    whiptail --title "PowerNeovim" --yesno "$msg" 10 70
    return $?
  fi
  read -r -p "$msg [y/N] " ans
  [[ "$ans" =~ ^[yY]$ ]]
}

ui_msgbox() {
  local msg="$1"
  if ui_has_whiptail && [[ "${POWERNEOVIM_NONINTERACTIVE:-0}" != "1" ]]; then
    whiptail --title "PowerNeovim" --msgbox "$msg" 12 72
  else
    printf "\n%s\n\n" "$msg"
  fi
}
