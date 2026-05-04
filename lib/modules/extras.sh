# shellcheck shell=bash
# Module: extras — configs auxiliares (btop, ranger, lazygit, lazydocker, picom, flameshot).

mod_extras_meta() {
  echo "Configs auxiliares (btop, ranger, lazygit, lazydocker, picom, flameshot)"
}

_PN_EXTRA_DIRS=(btop ranger lazygit lazydocker picom flameshot)

# Itera somente sobre os módulos cuja config existe no repo.
_vf_extras_present() {
  for d in "${_PN_EXTRA_DIRS[@]}"; do
    [[ -d "$POWERNEOVIM_HOME/home/.config/$d" ]] && echo "$d"
  done
}

mod_extras_install() {
  for d in $(_vf_extras_present); do
    link_safe "$POWERNEOVIM_HOME/home/.config/$d" "$HOME/.config/$d"
  done
}

mod_extras_links() {
  for d in $(_vf_extras_present); do
    printf '%s\t%s\n' "$POWERNEOVIM_HOME/home/.config/$d" "$HOME/.config/$d"
  done
}

mod_extras_doctor() {
  for d in $(_vf_extras_present); do
    if [[ -L "$HOME/.config/$d" ]]; then
      status_line 1 "$d: linkado"
    else
      status_line 0 "$d: não linkado"
    fi
  done
}
