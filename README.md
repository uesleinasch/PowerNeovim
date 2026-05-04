# PowerNeovim

CLI para replicar e compartilhar um ambiente de desenvolvimento
(**Neovim + AstroNvim, Zsh + Oh-My-Zsh + Powerlevel10k, Kitty, helpers
`myastro`/`mykitty` e ferramentas CLI**) em qualquer máquina **Ubuntu /
Debian / Pop!_OS**.

> **Não toca em git.** Assume que o usuário já tem `~/.gitconfig`,
> `~/.npmrc` e suas credenciais configuradas.
>
> **Node.js é opcional**: o módulo `node` instala o gerenciador de versões
> de sua escolha (`nvm` ou `n`) e o Node LTS. Se você já tem um deles,
> o módulo só garante o Node LTS e os PATHs no `~/.zshrc`.

## Princípios

- **Symlinks (estilo stow)**: as configs ficam em `~/PowerNeovim/home/...` e
  `$HOME/...` são symlinks para lá. Você edita o arquivo onde sempre editou
  e o "repo" reflete sozinho.
- **Idempotente**: rodar duas vezes não duplica nada nem cria backups vazios.
- **Sem segredos**: tokens e identidade pessoal ficam em `~/.zshrc.local`
  (ignorado, nunca empacotado).
- **Compartilhável**: `powerneovim share` gera um `.tar.gz` que o colega
  extrai em `$HOME` e roda `~/PowerNeovim/bin/powerneovim install`.

## Estrutura

```
~/PowerNeovim/
├── bin/powerneovim              # entrypoint da CLI
├── lib/
│   ├── core.sh               # log, link_safe, backup, sudo wrapper, dry-run
│   ├── ui.sh                 # TUI whiptail + fallback texto
│   └── modules/              # 10 módulos independentes
│       ├── apt.sh            # base: curl, ripgrep, fzf, jq, …
│       ├── fonts.sh          # MesloLGS NF (Powerlevel10k)
│       ├── zsh.sh            # zsh + OMZ + p10k + plugins
│       ├── nvim.sh           # binário Neovim em /opt
│       ├── astronvim.sh      # link de ~/.config/nvim
│       ├── kitty.sh          # Kitty + link da kitty.conf
│       ├── tools.sh          # eza, starship, lazygit, lazydocker, uv
│       ├── node.sh           # nvm OU n (escolha) + Node LTS
│       ├── helpers.sh        # link de myastro / mykitty
│       └── extras.sh         # btop, ranger, picom, flameshot, …
├── home/                     # estado canônico das configs
│   ├── .zshrc                # template comum (sourceia .zshrc.local)
│   ├── .p10k.zsh
│   └── .config/{nvim,kitty,btop,ranger,…}
├── home.local.example/       # personalização não versionada
├── bin-helpers/              # myastro, mykitty
├── docker/                   # Dockerfile para testar isolado
└── VERSION
```

## Uso rápido

```bash
# Instalação interativa (TUI com checkboxes)
~/PowerNeovim/bin/powerneovim install

# Tudo, sem perguntas
~/PowerNeovim/bin/powerneovim install --profile full --yes

# Subset
~/PowerNeovim/bin/powerneovim install --module zsh,fonts,helpers

# Só Node (escolha interativa entre nvm e n)
~/PowerNeovim/bin/powerneovim install --module node

# Node não-interativo, forçando o gerenciador
POWERNEOVIM_NODE_MANAGER=nvm ~/PowerNeovim/bin/powerneovim install --module node --yes
POWERNEOVIM_NODE_MANAGER=n   ~/PowerNeovim/bin/powerneovim install --module node --yes

# Simular sem executar nada
~/PowerNeovim/bin/powerneovim install --profile dev --dry-run --yes

# Diagnóstico
powerneovim doctor

# Empacotar para um colega
powerneovim share dotfiles-$(date +%Y%m%d).tar.gz
```

## Profiles

| Profile   | Inclui                                                                 |
|-----------|------------------------------------------------------------------------|
| `minimal` | apt + fonts + zsh + helpers                                            |
| `dev`     | minimal + nvim + astronvim + kitty + tools + node                      |
| `full`    | tudo (= dev + extras)                                                  |

## Comandos

| Comando            | Função                                                          |
|--------------------|-----------------------------------------------------------------|
| `install`          | Instala módulos (TUI / `--profile` / `--module`)                |
| `link`             | Refaz só os symlinks (sem reinstalar)                           |
| `unlink`           | Remove symlinks + restaura backups (`.pnbak.<timestamp>`)       |
| `status`           | Mostra symlinks gerenciados                                     |
| `doctor`           | Diagnóstico completo (versões, fontes, links, dependências)     |
| `share [arquivo]`  | Empacota o repo em `.tar.gz` (sem `home.local`, sem `.pnbak.*`) |
| `update`           | Atualiza P10k e plugins zsh (e dá hint para `:Lazy sync`)       |
| `help [tópico]`    | Ajuda                                                           |

## Módulo `node` (nvm ou n)

Instala um gerenciador de versões e o Node LTS, sem mexer em `~/.npmrc`.

**Quem é escolhido?** A precedência (de cima pra baixo):

1. Se já existe `~/.nvm` ou `~/n` (ou `n` no PATH) → reusa o que está lá.
2. `POWERNEOVIM_NODE_MANAGER=nvm|n` (env) → respeita a escolha.
3. Modo não-interativo (`--yes` / sem TTY) → default `nvm`.
4. Modo interativo → menu `whiptail` (ou prompt) perguntando.

**O que o instalador faz:**

| Manager | Onde instala     | Como o Node entra no PATH                              |
|---------|------------------|--------------------------------------------------------|
| `nvm`   | `~/.nvm` (v0.40.1) | `~/.zshrc` faz `source $NVM_DIR/nvm.sh` se existir    |
| `n`     | `~/n` (via `n-install -n`) | `~/.zshrc` prependa `~/n/bin` ao `PATH` se existir |

Ambos os casos: depois do install, é instalado o **Node LTS** (`nvm install --lts`
ou `n lts`) e o `~/.zshrc` do PowerNeovim já tem o auto-detect — basta
**reabrir o terminal** ou rodar `exec zsh`.

> **Idempotente.** Reexecutar `powerneovim install --module node` é seguro:
> se o gerenciador já existe, ele só garante o Node LTS e os PATHs.

## Personalização (`~/.zshrc.local`)

Copie o template e edite à vontade. O `~/.zshrc` gerenciado pelo PowerNeovim
faz `source ~/.zshrc.local` no final.

```bash
cp ~/PowerNeovim/home.local.example/.zshrc.local ~/.zshrc.local
$EDITOR ~/.zshrc.local
```

Use `~/.zshrc.local` para:
- aliases pessoais (VPN, Docker, etc.)
- toolchains específicas (JAVA_HOME, ghcup, gcloud SDK)
- segredos (tokens, chaves)

Esse arquivo nunca é tocado pelo PowerNeovim.

## Compartilhar com um colega

Da sua máquina:

```bash
~/PowerNeovim/bin/powerneovim share
# Gera: powerneovim-share-YYYYMMDD.tar.gz
```

Na máquina do colega:

```bash
tar -xzf powerneovim-share-YYYYMMDD.tar.gz -C $HOME
~/PowerNeovim/bin/powerneovim install
```

A TUI permite que ele desligue módulos que não quer. `--profile minimal`
deixa ele sem Neovim/Kitty caso não use.

## Testar antes de aplicar

Veja [`docker/README.md`](docker/README.md). Resumo:

```bash
docker build -t powerneovim-test -f docker/Dockerfile .
docker run -it --rm powerneovim-test bash -lc \
  '~/PowerNeovim/bin/powerneovim install --profile full --yes && powerneovim doctor'
```

## Atualizando configs

Como `$HOME/.zshrc` é symlink para `~/PowerNeovim/home/.zshrc`, **editar
qualquer arquivo de config já atualiza o repo**. Para aplicar em outras
máquinas: copie a pasta `~/PowerNeovim/` (via `powerneovim share`, USB, rsync,
ou — mais tarde — git push) e rode `powerneovim link`.

## O que NÃO faz (por design)

- Não instala / configura `git` (assumimos que você cuida).
- Não toca em `~/.gitconfig`, `~/.gitignore_global`, `~/.npmrc`.
- Não muda configurações do GNOME / desktop.
- Não roda `:Lazy sync` automático no Neovim — o Lazy.nvim pega na
  primeira execução.
- Não escolhe entre `nvm` e `n` por você quando está no modo interativo —
  o módulo `node` pergunta.

## Troubleshooting

| Sintoma                                       | Causa / fix                                                                   |
|-----------------------------------------------|--------------------------------------------------------------------------------|
| Powerlevel10k mostra ícones quebrados         | Selecione `MesloLGS NF` no terminal/IDE.                                       |
| `chsh` falhou no install                      | Comum em containers. Faça manualmente: `chsh -s $(command -v zsh)`.            |
| Plugins do Neovim não apareceram              | Abra `nvim` e aguarde o Lazy.nvim. Se travar: `:Lazy sync`.                    |
| `powerneovim doctor` reclama de symlink          | Rode `powerneovim link` para refazer.                                             |
| Quero voltar à config anterior                | `powerneovim unlink` — restaura os `.pnbak.<timestamp>` mais recentes.            |
| `node`/`npm` não aparecem após install        | Reabra o terminal ou rode `exec zsh` — o `~/.zshrc` carrega `nvm`/`n` no startup. |
| Quero forçar `nvm` (ou `n`) num install `--yes` | `POWERNEOVIM_NODE_MANAGER=nvm powerneovim install --module node --yes`.         |
| Erro `unknown style 'zdiff3'` no `git`        | Git < 2.35; use `merge.conflictstyle=diff3` ou atualize via `ppa:git-core/ppa`. |
