# shellcheck shell=bash
# Module: zsh — zsh + Oh-My-Zsh + Powerlevel10k + plugins + linka ~/.zshrc, ~/.p10k.zsh.

mod_zsh_meta() {
  echo "Zsh + Oh-My-Zsh + Powerlevel10k + plugins (autosuggestions/syntax-highlighting)"
}

_PN_OMZ_DIR="$HOME/.oh-my-zsh"
_PN_OMZ_CUSTOM="${ZSH_CUSTOM:-$_PN_OMZ_DIR/custom}"

mod_zsh_install() {
  require_supported_distro
  if ! has_cmd zsh; then
    apt_update_once
    apt_install zsh
  fi

  if [[ ! -d "$_PN_OMZ_DIR" ]]; then
    log_info "Instalando Oh-My-Zsh…"
    if [[ "$DRY_RUN" == "1" ]]; then
      log_dry "curl https://.../ohmyzsh/install.sh | sh (RUNZSH=no CHSH=no KEEP_ZSHRC=yes)"
    else
      RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL --connect-timeout 15 --max-time 300 \
          https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
  else
    log_info "OK: Oh-My-Zsh já instalado"
  fi

  _PN_OMZ_CUSTOM="${ZSH_CUSTOM:-$_PN_OMZ_DIR/custom}"
  run mkdir -p "$_PN_OMZ_CUSTOM/themes" "$_PN_OMZ_CUSTOM/plugins"

  clone_or_pull \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$_PN_OMZ_CUSTOM/themes/powerlevel10k" \
    "powerlevel10k"

  clone_or_pull \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "$_PN_OMZ_CUSTOM/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions"

  clone_or_pull \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$_PN_OMZ_CUSTOM/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

  link_safe "$POWERNEOVIM_HOME/home/.zshrc"   "$HOME/.zshrc"
  link_safe "$POWERNEOVIM_HOME/home/.p10k.zsh" "$HOME/.p10k.zsh"

  _vf_set_default_shell
}

# chsh exige a senha do usuário (não do sudo). Em modo não-interativo / sem TTY
# ele simplesmente trava — então pulamos e enfileiramos como tarefa manual.
_vf_set_default_shell() {
  local zsh_path; zsh_path="$(command -v zsh || true)"
  [[ -z "$zsh_path" ]] && return 0
  [[ "${SHELL:-}" == "$zsh_path" ]] && return 0

  if [[ "$DRY_RUN" == "1" ]]; then
    log_dry "chsh -s $zsh_path"
    return 0
  fi

  if [[ "${POWERNEOVIM_NONINTERACTIVE:-0}" == "1" ]] || ! [[ -t 0 ]]; then
    log_warn "chsh requer senha interativa — pulando (será reportado no fim)."
    post_install_note "Definir zsh como shell padrão: chsh -s $zsh_path"
    return 0
  fi

  log_info "Definindo zsh como shell padrão (vai pedir sua senha; 60s timeout)…"
  if ! timeout 60 chsh -s "$zsh_path" 2>/dev/null; then
    log_warn "chsh falhou ou expirou — adicionado às tarefas manuais."
    post_install_note "Definir zsh como shell padrão: chsh -s $zsh_path"
  fi
}

mod_zsh_links() {
  printf '%s\t%s\n' "$POWERNEOVIM_HOME/home/.zshrc"   "$HOME/.zshrc"
  printf '%s\t%s\n' "$POWERNEOVIM_HOME/home/.p10k.zsh" "$HOME/.p10k.zsh"
}

mod_zsh_doctor() {
  has_cmd zsh && status_line 1 "zsh: $(zsh --version 2>/dev/null)" || status_line 0 "zsh: não instalado"
  [[ -d "$_PN_OMZ_DIR" ]] && status_line 1 "oh-my-zsh: presente" || status_line 0 "oh-my-zsh: ausente"
  [[ -d "$_PN_OMZ_CUSTOM/themes/powerlevel10k" ]] && status_line 1 "powerlevel10k: presente" || status_line 0 "powerlevel10k: ausente"
  [[ -L "$HOME/.zshrc" ]] && status_line 1 "~/.zshrc: linkado" || status_line 0 "~/.zshrc: não linkado por PowerNeovim"
  [[ -L "$HOME/.p10k.zsh" ]] && status_line 1 "~/.p10k.zsh: linkado" || status_line 0 "~/.p10k.zsh: não linkado"
}
