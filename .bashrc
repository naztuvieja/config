# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


##Handy custom functions
function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/bin/ip addr | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    INET_IP=$(curl -s ipecho.net/plain)
    echo ${MY_IP:-"Not connected"}
    echo $INET_IP
}

function mydf()         # Pretty-print of 'df' output.
{                       # Inspired by 'dfc' utility.
    for fs ; do

        if [ ! -d $fs ]
        then
          echo -e $fs" :No such file or directory" ; continue
        fi

        local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
        local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
        local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
        local out="["
        for ((j=0;j<20;j++)); do
            if [ ${j} -lt ${nbstars} ]; then
               out=$out"*"
            else
               out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}

function mymem()
{
        BC=/usr/bin/bc
        GREP=/bin/grep
        AWK=/bin/awk
        FREE=/usr/bin/free
        TAIL=/usr/bin/tail
        HEAD=/usr/bin/head

        set $($FREE |$GREP "Mem")

        MEMTOTAL=$2
        MEMUSED=$3
        MEMFREE=$4
        MEMBUFFERS=$6
        MEMCACHED=$7

        set  $($FREE |$GREP "Swap")
        SWTOTAL=$2
        SWUSED=$3
        SWFREE=$4

        REALMEMUSED=$(echo $MEMUSED - $MEMBUFFERS - $MEMCACHED | $BC)
        USEPCTM=$(echo "scale=2; $REALMEMUSED / $MEMTOTAL * 100" |$BC -l )
	if [ $SWTOTAL != 0 ]; then
	        USEPCTS=$(echo "scale=2; $SWUSED/$SWTOTAL * 100 " | $BC -l )
	else
		USEPCTS=0
	fi
        echo "Mem:$USEPCTM%  Swap:$USEPCTS%"

}

function ii()   # Get current host related info.
{
    echo -e "\nYou are logged on " ; hostname
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a ; w | head -1
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs | cut -d " " -f1 | sort | uniq
    #echo -e "\n${BRed}Current date :$NC " ; date
    #echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; mymem ; free -m
    echo -e "\n${BRed}Diskspace :$NC " ; mydf $(mount | grep "^/" | awk '{print $3}' | paste -sd" ")
    echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    #echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}


# Git on prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[00;32m\]\u@\h \[\033[00;36m\]\w\[\033[00;33m\]$(__git_ps1)\[\033[00;32m\]\$\[\033[00m\] '

# MY PATH
export PATH=$PATH:/home/machine/bin

# My custom Alias
alias ttmux='/home/machine/bin/tmux-launch.sh'
