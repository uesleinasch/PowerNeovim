# ~/.zshrc gerenciado pelo PowerNeovim.
# Editar este arquivo edita o repo (~/PowerNeovim/home/.zshrc) via symlink.
# Customizações pessoais devem ir em ~/.zshrc.local (ignorado pelo PowerNeovim).

# ---- Powerlevel10k instant prompt (deve ficar perto do topo) ----
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- PATH base ----
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
[[ -d /opt/nvim-linux-x86_64/bin ]] && export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# ---- Oh-My-Zsh ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  z
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Defaults razoáveis
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
HIST_STAMPS="yyyy-mm-dd"

# instant-prompt sem mensagens de console
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

source "$ZSH/oh-my-zsh.sh"

# ---- Editor ----
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# ---- Aliases comuns ----
alias l='ls -lh'
alias la='ls -lha'
alias ll='ls -lh'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# eza substitui ls quando disponível
if command -v eza >/dev/null 2>&1; then
  alias l='eza -lh --git --icons'
  alias la='eza -lha --git --icons'
  alias ll='eza -lh --git --icons'
  alias tree='eza --tree --icons'
fi

# bat -> batcat em Debian/Ubuntu
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi

# fd -> fdfind em Debian/Ubuntu
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# ---- Integrações opcionais ----
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

# Powerlevel10k (config gerada por p10k configure)
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# ---- Personalização local (não versionada) ----
# Coloque aqui aliases, funções, exports e segredos específicos da máquina/usuário.
# Veja: ~/PowerNeovim/home.local.example/.zshrc.local
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
