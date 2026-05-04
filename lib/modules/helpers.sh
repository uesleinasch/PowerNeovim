# shellcheck shell=bash
# Module: helpers — symlink dos seus utilitários myastro/mykitty para ~/.local/bin.

mod_helpers_meta() {
  echo "Utilitários myastro e mykitty (helpers de ajuda do AstroNvim e Kitty)"
}

_PN_HELPERS=(myastro mykitty)

mod_helpers_install() {
  ensure_local_bin
  for h in "${_PN_HELPERS[@]}"; do
    local src="$POWERNEOVIM_HOME/bin-helpers/$h"
    [[ -f "$src" ]] || { log_warn "helper ausente no repo: $h"; continue; }
    if [[ ! -x "$src" ]]; then
      if [[ "$DRY_RUN" == "1" ]]; then
        log_dry "chmod +x $src"
      else
        chmod +x "$src" 2>/dev/null \
          || log_warn "Não foi possível setar +x em $src (FS read-only?)"
      fi
    fi
    link_safe "$src" "$HOME/.local/bin/$h"
  done
}

mod_helpers_links() {
  for h in "${_PN_HELPERS[@]}"; do
    printf '%s\t%s\n' "$POWERNEOVIM_HOME/bin-helpers/$h" "$HOME/.local/bin/$h"
  done
}

mod_helpers_doctor() {
  for h in "${_PN_HELPERS[@]}"; do
    if [[ -L "$HOME/.local/bin/$h" ]]; then
      status_line 1 "$h: linkado"
    elif [[ -e "$HOME/.local/bin/$h" ]]; then
      status_line 0 "$h: existe mas não é symlink do PowerNeovim"
    else
      status_line 0 "$h: ausente"
    fi
  done
}
