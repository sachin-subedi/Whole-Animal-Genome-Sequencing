# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# commented by ZH.2023.10.10
# echo 'export PATH="/path/to/miniconda3/bin:$PATH"' >> ~/.bashrc

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

# commented by ZH.2023.10.10
# export PATH="/path/to/miniconda3/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/apps/eb/Mamba/23.1.0-4/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/apps/eb/Mamba/23.1.0-4/etc/profile.d/conda.sh" ]; then
        . "/apps/eb/Mamba/23.1.0-4/etc/profile.d/conda.sh"
    else
        export PATH="/apps/eb/Mamba/23.1.0-4/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<