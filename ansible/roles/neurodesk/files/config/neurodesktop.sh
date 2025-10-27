# Not an interactive shell?
[[ $- == *i* ]] || return 0

# Load modules
if [ -f /usr/share/module.sh ]; then
    . /usr/share/module.sh
fi

# Load Neurodesktop environment vars
if [ -f /opt/neurodesktop/environment_variables.sh ]; then
    . /opt/neurodesktop/environment_variables.sh
fi
