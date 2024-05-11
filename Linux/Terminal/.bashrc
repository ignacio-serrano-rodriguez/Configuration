# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Colors
#BLACK=$(tput setaf 0)
#RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
#LIME_YELLOW=$(tput setaf 190)
#YELLOW=$(tput setaf 3)
#POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
#MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
#WHITE=$(tput setaf 7)

# Modifiers
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
#BLINK=$(tput blink)
#REVERSE=$(tput smso)
#UNDERLINE=$(tput smul)

# Custom prompt
PS1="\[${BRIGHT}\]\[${GREEN}\]\u \[${BRIGHT}\]\[${CYAN}\]\H \[${BRIGHT}\]\[${BLUE}\]\w\[${NORMAL}\] "