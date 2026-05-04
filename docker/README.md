# Testando o PowerNeovim no Docker

Use isto para validar antes de aplicar na máquina real.

## Build

```bash
cd ~/PowerNeovim
docker build -t powerneovim-test -f docker/Dockerfile .
```

A imagem é Ubuntu 22.04, usuário `dev` com sudo NOPASSWD, e já tem o repo
copiado em `/home/dev/PowerNeovim`.

## Cenários de teste

### 1) Install completo (não-interativo)

```bash
docker run -it --rm powerneovim-test bash -lc \
  '~/PowerNeovim/bin/powerneovim install --profile full --yes'
```

### 2) Modo interativo (TUI)

```bash
docker run -it --rm powerneovim-test
# dentro do container:
powerneovim install
```

### 3) Dry-run (não executa nada)

```bash
docker run -it --rm powerneovim-test bash -lc \
  '~/PowerNeovim/bin/powerneovim install --profile dev --yes --dry-run'
```

### 4) Subset de módulos

```bash
docker run -it --rm powerneovim-test bash -lc \
  '~/PowerNeovim/bin/powerneovim install --module zsh,fonts,helpers --yes'
```

### 5) Doctor depois do install

```bash
docker run -it --rm powerneovim-test bash -lc \
  '~/PowerNeovim/bin/powerneovim install --profile full --yes && powerneovim doctor'
```

## Iteração rápida (mount do host)

Para iterar nos scripts sem rebuild:

```bash
docker run -it --rm \
  -v "$PWD:/home/dev/PowerNeovim" \
  powerneovim-test bash -lc 'cd ~/PowerNeovim && bin/powerneovim install --profile full --yes'
```

> Atenção: nessa forma os symlinks que o powerneovim cria no `$HOME` do
> container apontam para `/home/dev/PowerNeovim/...` (o mount). É exatamente
> isto que aconteceria na sua máquina real.

## O que validar

- [ ] `powerneovim install --dry-run --yes` lista as ações sem fazer nada.
- [ ] `powerneovim install --profile full --yes` termina sem erro.
- [ ] `powerneovim doctor` mostra `✓` em todos os módulos.
- [ ] `ls -la ~/.config/nvim ~/.zshrc ~/.p10k.zsh` mostra symlinks para o repo.
- [ ] `nvim` abre e o Lazy.nvim baixa os plugins.
- [ ] Backup: rode `install` duas vezes — não deve criar `.pnbak.*` na segunda.
- [ ] `powerneovim unlink` remove os symlinks (e restaura backups se houver).

## Limitações conhecidas em container

- `chsh` costuma falhar (PAM) — o módulo zsh continua mesmo assim.
- A fonte só funciona dentro de um terminal gráfico (não na shell do
  container). Para validar visualmente, use a fonte na máquina real.
- Kitty pode falhar ao instalar o launcher `.desktop` — esperado em headless.
