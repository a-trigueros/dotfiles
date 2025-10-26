# ----- Basic options -----
setopt autocd              # cd implicite
setopt correct             # corrige les fautes de frappe
setopt histignoredups      # pas de doublons dans l’historique
setopt sharehistory        # partage entre sessions

# ----- Compinit (Zsh completions) -----
# Uses compinit cache if lesser than 24h
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi

fpath+=('/opt/homebrew/share/zsh/site-functions')
# fzf
ZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)

# ----- Prompt -----
eval "$(starship init zsh)"

# ----- Completion (Carapace) -----
eval "$(carapace _carapace)"

# ----- History (Atuin) -----
# Chargé uniquement en mode interactif
if [[ $- == *i* ]]; then
  eval "$(atuin init zsh)"

  alias asl="atuin script list"
  alias asr="atuin script run"

fi

# ----- Fast cd (zoxide) -----
eval "$(zoxide init zsh)"

source $HOME/.config/zsh/jj.zsh

# ----- Fuzzy finder (fzf) -----
# Only in interactive shell
if [[ $- == *i* ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ----- Autosuggestions -----
if [[ $- == *i* ]]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ------ Yazi --------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ----- Syntax highlighting -----
# ⚠️ always last, and only in interactive mode
if [[ $- == *i* ]]; then
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

source $HOME/.config/zsh/node.zsh
source $HOME/.config/zsh/devtoolstosort.zsh

# ----- Editor -----
export EDITOR=nvim
export VISUAL=nvim
export PAGER="less -RFX"

# ----- Vi mode -----
set -o vi

# ----- bat configuration -----
export BAT_THEME="Catppuccin Macchiato"
export BAT_STYLE="numbers,changes,header,grid"
export BAT_PAGER="less -RF"

# bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# ----- eza configuration -----
# Default eza options
export EZA_COLORS="da=38;5;245:sn=38;5;28:sb=38;5;28:ur=38;5;40:uw=38;5;40:ux=38;5;40:ue=38;5;40:gr=38;5;226:gw=38;5;226:gx=38;5;226:tr=38;5;196:tw=38;5;196:tx=38;5;196"
export EZA_ICON_SPACING=2

# eza aliases
alias ls='eza --color=always --icons=always'
alias ll='eza -lbF --git --icons=always --color=always'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons=always --color=always'
alias lt='eza --tree --level=2 --icons=always --color=always'
alias ltt='eza --tree --level=3 --icons=always --color=always'
alias lttt='eza --tree --level=4 --icons=always --color=always'
alias lg='eza -lbhHigUmuSa@ --git --color=always --icons=always'  # avec attributs étendus
alias lm='eza -lbhHigUmuSa --sort=modified --color=always --icons=always'  # trié par date de modification
alias lz='eza -lbhHigUmuSa --sort=size --color=always --icons=always'  # trié par taille

# Navigation
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
LISTMAX=0
