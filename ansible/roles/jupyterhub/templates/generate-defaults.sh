#!/bin/bash

IFS=$'\n';
while read -r LINE; do
  if echo "$LINE" | grep -qE '^# c\.'; then
    KEY=$(echo "$LINE" | awk -F' = ' '{print $1}' | sed 's/^# //g')
    NEWKEY=$(echo "$LINE" | awk -F' = ' '{print tolower($1)}' | sed -e 's/^# c\.//g' -e 's/\./_/g')

    # If the config variable doesn't start with jupyterhub, we'll prefix it
    if [[ "$NEWKEY" != "jupyterhub"* ]]; then
      NEWKEY="jupyterhub_${NEWKEY}"
    fi

    VAL=$(echo $LINE | awk -F' = ' '{print $2}')
    echo "#$NEWKEY: $VAL"
  fi
done < jupyterhub_config.py
