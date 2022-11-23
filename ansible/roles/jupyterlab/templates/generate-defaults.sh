#!/bin/bash

IFS=$'\n';
while read LINE; do
  if echo "$LINE" | grep -qE '^#c\.'; then
    KEY=$(echo $LINE | awk -F' = ' '{print $1}' | sed 's/^#//g')
    NEWKEY=$(echo $LINE | awk -F' = ' '{print tolower($1)}' | sed -e 's/^#c\./jupyter_lab_/g' -e 's/\./_/g')
    VAL=$(echo $LINE | awk -F' = ' '{print $2}')
    echo "#$NEWKEY: $VAL"
  fi
done < ~/.jupyter/jupyter_notebook_config.py
