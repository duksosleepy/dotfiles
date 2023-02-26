# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Created by newuser for 5.8
PROMPT='%F{202}d%f%F{208}u%f%F{214}k%f%F{220}@%f%F{220}sh%f%F{214}e%f%F{208}ll:%f%F{202}%1~/%f %F{214}%#%f '
fpath+=~/.zfunc
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
export TERM=xterm-256color
export GTAGSCONF=usr/local/share/gtags/gtags.conf
export GTAGSLABEL=pygments

