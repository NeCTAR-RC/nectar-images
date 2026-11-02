# Not an interactive shell?
[[ $- == *i* ]] || return 0

# Load modules
if [ -f /usr/share/module.sh ]; then
    . /usr/share/module.sh
fi

# Enable `conda activate` without per-user `conda init`
if [ -x /opt/conda/bin/conda ]; then
    eval "$(/opt/conda/bin/conda shell.bash hook)"
fi

# Load Neurodesktop environment vars
if [ -f /opt/neurodesktop/environment_variables.sh ]; then
    . /opt/neurodesktop/environment_variables.sh
fi
