# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS
# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e
# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}
# The file to save the history in.
if (( ! ${+HISTFILE} )) typeset -g HISTFILE=${ZDOTDIR:-${HOME}}/.zhistory
# The maximum number of events stored internally and saved in the history file.
# The former is greater than the latter in case user wants HIST_EXPIRE_DUPS_FIRST.
HISTSIZE=20000
SAVEHIST=10000
# Don't display duplicates when searching the history.
setopt HIST_FIND_NO_DUPS
# Don't enter immediate duplicates into the history.
setopt HIST_IGNORE_DUPS
# Don't execute the command directly upon history expansion.
setopt HIST_VERIFY
# Cause all terminals to share the same history 'session'.
setopt SHARE_HISTORY
# Allow comments starting with `#` in the interactive shell.
setopt INTERACTIVE_COMMENTS

# pretty shell (autocompletion, highlighting, etc)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # Set what highlighters will be used. See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
autoload -U compinit; compinit # autocompletion
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# end pretty shell

# FZF
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if (( ${+commands[bat]} )); then
  export FZF_CTRL_T_OPTS="--preview 'command bat --color=always --line-range :500 {}' ${FZF_CTRL_T_OPTS}"
fi
if (( ${+commands[fd]} )); then
  export FZF_DEFAULT_COMMAND='command fd -c always -H --no-ignore-vcs -E .git -tf'
  export FZF_ALT_C_COMMAND='command fd -c always -H --no-ignore-vcs -E .git -td'
  _fzf_compgen_path() {
    command fd -c always -H --no-ignore-vcs -E .git -tf . "${1}"
  }
  _fzf_compgen_dir() {
    command fd -c always -H --no-ignore-vcs -E .git -td . "${1}"
  }
  export FZF_DEFAULT_OPTS="--ansi ${FZF_DEFAULT_OPTS}"
fi
if (( ${+FZF_DEFAULT_COMMAND} )) export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
# end FZF

# keybindings
typeset -gA key_info
# "showkay -a" for keycodes
key_info=(
	'ControlLeft'		'^[[1;5D'
	'ControlRight' 		'^[[1;5C'
	'Backspace'    		'^?'
	'ControlBackspace'    	'^H'
	'Delete'       		'^[[3~'
	'ControlDelete'      	'^[[3;5~'
	'End'          		'^[[F'
	'Home'         		'^[[H'
)

# "showkey -a" to get key codes
bindkey ${(s: :)key_info[ControlLeft]} backward-word
bindkey ${(s: :)key_info[ControlRight]} forward-word
bindkey ${(s: :)key_info[ControlBackspace]} backward-kill-word
bindkey ${(s: :)key_info[ControlDelete]} kill-word
bindkey ${(s: :)key_info[Delete]} delete-char
bindkey ${(s: :)key_info[Home]} beginning-of-line
bindkey ${(s: :)key_info[End]} end-of-line
# end keybindings

# locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
# end locale

# lenovo power management
(which pacman && pacman -Qi acpi_call) > /dev/null 2>&1
retVal=$?
if [ $retVal -eq 0 ]; then
  alias savepower="sh -c \"modprobe acpi_call && echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' > /proc/acpi/call\""
  alias performance="sh -c \"modprobe acpi_call && echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' > /proc/acpi/call\""
  alias rapidchargeon="sh -c \"modprobe acpi_call && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' > /proc/acpi/call\""
  alias rapidchargeoff="sh -c \"modprobe acpi_call && echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' > /proc/acpi/call\""
fi
# end lenovo power management

# exa aliases
if (( ${+commands[exa]} )); then
  export EXA_COLORS='da=1;34:gm=1;34'
  alias ls='exa --group-directories-first'
  alias ll='ls -l --git'        # Long format, git status
  alias l='ll -a'               # Long format, all files
  alias lr='ll -T'              # Long format, recursive as a tree
  alias lx='ll -sextension'     # Long format, sort by extension
  alias lk='ll -ssize'          # Long format, largest file size last
  alias lt='ll -smodified'      # Long format, newest modification time last
  alias lc='ll -schanged'       # Long format, newest status change (ctime) last
fi
# end exa

# youtube aliases
if (( ${+commands[yt-dlp]} )); then
  alias downloadvid="yt-dlp --external-downloader aria2c --external-downloader-args '-c -j 3 -x 3 -s 3 -k 1M'"
  alias download_playlist='downloadvid --ignore-errors --continue --no-overwrites --download-archive progress.txt'
fi
# end youtube aliases

# rsync aliases
if (( ${+commands[rsync]} )); then
  alias rsync-copy="rsync -avz --progress -h"
  alias rsync-move="rsync -avz --progress -h --remove-source-files"
  alias rsync-update="rsync -avzu --progress -h"
  alias rsync-synchronize="rsync -avzu --delete --progress -h"
fi
# end rsync aliases

# gpg gets upset if I don't set this
if (( ${+commands[gpg]} )); then export GPG_TTY=$(tty); fi

# use fzf for tab autocomplete
[[ -f ~/fzf-tab/fzf-tab.plugin.zsh ]] && source ~/fzf-tab/fzf-tab.plugin.zsh

# start starship. supposedly must be last in file
if (( ${+commands[starship]} )); then
  eval "$(starship init zsh)"
fi
