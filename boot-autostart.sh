#!/bin/bash

CONFIG="/home/andre/projects/boot-setup/config.txt"

if [ ! -f "$CONFIG" ]; then
  notify-send "boot-setup" "Nenhuma configuração encontrada!"
  exit 1
fi

while IFS=: read -r ws app; do
  [ -z "$app" ] && continue
  bspc desktop -f "$ws"
  bash -c "$app &"
  sleep 2
done < "$CONFIG"