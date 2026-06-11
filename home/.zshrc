# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
zsh-autosuggestions
zsh-syntax-highlighting

)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Use the VPN for
alias jactonet='cd ~/vpn && sudo openvpn --config vpn.ovpn'
alias sunshine-start='systemctl --user start sunshine.service'
alias sunshine-stop='systemctl --user stop sunshine.service'
alias sunshine-restart='systemctl --user restart sunshine.service'
alias sunshine-status='systemctl --user status sunshine.service'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$PATH:/path/to/node/bin"
export PATH="/home/unascimento@jacto.local/n/bin:$PATH"



[ -f "/home/unascimento@jacto.local/.ghcup/env" ] && . "/home/unascimento@jacto.local/.ghcup/env" # ghcup-env


# Load Angular CLI autocompletion.
source <(ng completion script)
export PATH="/home/unascimento@jacto.local/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/unascimento@jacto.local/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/unascimento@jacto.local/JACTO/repositories/workflow/exec -l /usr/bin/zsh/google-cloud-sdk/path.zsh.inc' ]; then . '/home/unascimento@jacto.local/JACTO/repositories/workflow/exec -l /usr/bin/zsh/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/unascimento@jacto.local/JACTO/repositories/workflow/exec -l /usr/bin/zsh/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/unascimento@jacto.local/JACTO/repositories/workflow/exec -l /usr/bin/zsh/google-cloud-sdk/completion.zsh.inc'; fi
export PATH=$PATH:~/google-cloud-sdk/bin
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

excalidraw() {
  IMAGE_NAME="excalidraw/excalidraw:latest"
  CONTAINER_NAME="excalidraw"
  DEFAULT_PORT=5000

  # Verifica se o container já está rodando
  if docker ps --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✅ Excalidraw já está rodando."
    return 0
  fi

  # Verifica se a porta padrão já está em uso
  if lsof -i :$DEFAULT_PORT &>/dev/null; then
    echo "⚠️ Porta $DEFAULT_PORT já está em uso. Buscando outra porta livre..."
    PORT=$(comm -23 <(seq 5000 6000 | sort) <(lsof -i -P -n | grep LISTEN | awk '{print $9}' | sed 's/.*://'))
    PORT=$(echo "$PORT" | head -n 1)
    if [ -z "$PORT" ]; then
      echo "❌ Não foi possível encontrar uma porta livre."
      return 1
    fi
    echo "➡️ Usando porta $PORT"
  else
    PORT=$DEFAULT_PORT
  fi

  # Inicia o container
  docker run --rm -dit --name $CONTAINER_NAME -p ${PORT}:80 $IMAGE_NAME
  echo "🚀 Excalidraw iniciado em http://localhost:${PORT}"
}

function devrifyt() {
  ssh -t rifyt "cd domains/rifyt.com/public_html/dev && export TERM=xterm-256color && exec bash -l"
}


# Penpot aliases
alias penpot-start='cd /home/unascimento@jacto.local/penpot && docker compose -p penpot -f docker-compose.yaml up -d && echo "Penpot iniciado em http://localhost:9001"'
alias penpot-stop='cd /home/unascimento@jacto.local/penpot && docker compose -p penpot -f docker-compose.yaml down && echo "Penpot parado"'
alias penpot-update='cd /home/unascimento@jacto.local/penpot && docker compose -f docker-compose.yaml pull && echo "Imagens atualizadas. Execute penpot-start para aplicar as atualizações"'
alias penpot-logs='cd /home/unascimento@jacto.local/penpot && docker compose -p penpot logs -f'
alias penpot-status='cd /home/unascimento@jacto.local/penpot && docker compose -p penpot ps'
# End Penpot aliases
alias dbeaver-max="snap run dbeaver-ce -vmargs -Xms512m -Xmx1096m"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
export _JAVA_OPTIONS="-Dsun.java2d.opengl=false"

# Configuração Docker-X11-Manager
export PATH="/home/unascimento@jacto.local/SecondMachine/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Kitty: comandos de sessão (ksave/kload)
[ -f ~/.config/kitty/session.zsh ] && source ~/.config/kitty/session.zsh
