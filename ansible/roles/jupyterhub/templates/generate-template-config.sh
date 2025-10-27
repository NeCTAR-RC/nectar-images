#!/bin/bash

#
# Generate a default JupyterHub config with:
#   $ jupyterhub --generate-config
# Then run this script to generate the Ansible config
# template.
#
# You might want to run dos2unix on it afterwards too.
#

IFS=$'\n';
while read -r LINE; do
  if echo "$LINE" | grep -qE '^# c\.'; then
    KEY=$(echo "$LINE" | awk -F' = ' '{print $1}' | sed 's/^# //g')
    NEWKEY=$(echo "$LINE" | awk -F' = ' '{print tolower($1)}' | sed -e 's/^# c\.//g' -e 's/\./_/g')

    # If the config variable doesn't start with jupyterhub, we'll prefix it
    if [[ "$NEWKEY" != "jupyterhub"* ]]; then
      NEWKEY="jupyterhub_${NEWKEY}"
    fi

    #VAL=$(echo "$LINE" | awk -F' = ' '{print $2}')
    echo "{% if $NEWKEY is defined %}"
    if echo "$LINE" | grep -qE '(True|False)'; then
      echo "$KEY = {{ $NEWKEY | bool }}"
    elif echo "$LINE" | grep -q "= None"; then
      echo "$KEY = '{{ $NEWKEY }}'"
    elif echo "$LINE" | grep -q "= '"; then
      echo "$KEY = '{{ $NEWKEY }}'"
    else
      echo "$KEY = {{ $NEWKEY }}"
    fi
    echo "{% else %}"
    echo "$LINE"
    echo "{% endif %}"
  else
    echo "$LINE"
  fi
done < jupyterhub_config.py
