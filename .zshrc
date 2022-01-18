
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast git-extras zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Exports
# ==============================
export RAILS_ENV=development
export PATH="$HOME/.rbenv/shims:/usr/local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/bin:$PATH"
export LC_ALL="en_US.UTF-8"
export EDITOR=nvim

# Aliases
# ==============================
alias zshrc='e ~/.zshrc'
alias e='nvim'
alias st='git status -sb'
alias gp='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)'
alias gd='git diff'
alias gpull='git pull --rebase'
alias gcom="git commit -m"
alias gcam="git add . && git commit -m"
alias gb="git b | FZF"
alias ytdl="youtube-dl --extract-audio --audio-format mp3 --exec 'mv {} ~/Music/iTunes/iTunes\ Media/Automatically\ Add\ To\ iTunes.localized/'"
alias gpv="gh pr view"
alias gcm="git checkout master || git checkout main"
alias compose="docker compose"
alias ll='exa --long --header --group --git --modified --color-scale'
alias ghrw='gh run watch && osascript -e "notify \"DONE\""'

function notifyFunction {
  osascript -e "display notification \"$1\""
}
alias notify="notifyFunction"

# Don't shame me, I purchased vmware long ago but can't find my license key
alias reset-vmware-license='sudo rm /Library/Preferences/VMware\ Fusion/license-fusion*'
alias grc="git rebase --continue"

alias tf="terraform"
alias alogs='awslogs get $(awslogs groups | fzf) ALL -G -w -i 1'
# alias plogs='AWS_PROFILE=production;awslogs get $(awslogs groups | fzf) ALL -G -w -i 2'
# alias slogs='AWS_PROFILE=staging;awslogs get $(awslogs groups | fzf) ALL -G -w -i 2'
alias slogs='AWS_PROFILE=staging;aws logs tail --follow --format short $(aws logs describe-log-groups | jq -r ".logGroups[].logGroupName" | fzf)'
alias plogs='AWS_PROFILE=production;aws logs tail --follow --format short $(aws logs describe-log-groups | jq -r ".logGroups[].logGroupName" | fzf)'
alias gprc="checkoutPr"
function checkoutPr {
  gh pr checkout $(gh pr list | fzf | awk '{print $1;}')
}

# Simple function to tell how much longer is remaining on an ssl certificate
function check-ssl-remaining {
  echo | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -dates
}

# Load rbenv
eval "$(rbenv init -)"

# CTRL-G - Paste the selected git modified file path(s) into the command line
__fzf_git_file() {
  local cmd="${FZF_CTRL_G_COMMAND:-command git ls-files -m}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_G_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-git-file-widget() {
  emulate -L zsh
  LBUFFER="${LBUFFER}$(__fzf_git_file)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle     -N   fzf-git-file-widget
bindkey "^G" fzf-git-file-widget

# CTRL-L - Paste the selected git branch file path(s) into the command line
__fzf_git_branch() {
  local cmd="${FZF_CTRL_B_COMMAND:-command git b}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_G_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-git-branch-widget() {
  emulate -L zsh
  LBUFFER="${LBUFFER}$(__fzf_git_branch)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle     -N   fzf-git-branch-widget
bindkey "^L" fzf-git-branch-widget

# [[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/postgresql@9.4/bin:$PATH"
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/Library/Python/3.7/bin:$PATH"

fpath=(/usr/local/share/zsh-completions $fpath)

if [ -d "$HOME/adb/platform-tools" ] ; then
  export PATH="$HOME/adb/platform-tools:$PATH"
fi

_direnv_hook() {
  eval "$(direnv export zsh)";
}
typeset -ag precmd_functions;
if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
  precmd_functions+=_direnv_hook;
fi
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
export PATH="/usr/local/opt/postgresql@10/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export DOCKER_BUILDKIT=1

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# PRIVATE
export AWS_PROFILE=dev
export AWS_REGION=us-west-2

# include our secretsrc
source ~/.secretsrc

export DISABLE_AUTO_TITLE='true'

