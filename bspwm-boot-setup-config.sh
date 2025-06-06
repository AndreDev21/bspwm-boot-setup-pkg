#!/bin/bash

# Define o diretório e o arquivo de configuração usando variáveis de ambiente
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bspwm-boot-setup"
CONFIG_FILE="$CONFIG_DIR/config.txt"

# Cria o diretório de configuração se ele não existir
mkdir -p "$CONFIG_DIR"

# Limpa o arquivo de configuração no início
> "$CONFIG_FILE"

# Mapeia os aplicativos com base nos arquivos .desktop
declare -A APP_COMMANDS
while IFS= read -r file; do
  NAME=$(grep -m1 '^Name=' "$file" | cut -d= -f2)
  EXEC=$(grep -m1 '^Exec=' "$file" | cut -d= -f2 | sed 's/ %.*//')
  if [[ -n "$NAME" && -n "$EXEC" ]]; then
    APP_COMMANDS["$NAME"]="$EXEC"
  fi
done < <(find /usr/share/applications ~/.local/share/applications -name '*.desktop' -print 2>/dev/null)

# Usa 'mapfile' para criar o array de nomes de forma segura, preservando espaços
mapfile -t APP_NAMES < <(printf "%s\n" "${!APP_COMMANDS[@]}" | sort)

# Lista de workspaces detectados pelo bspwm
WORKSPACES=$(bspc query -D --names | sort -n)

# Itera sobre cada workspace para o usuário selecionar os aplicativos
for WS in $WORKSPACES; do
  APP_SELECTIONS=()
  for APP in "${APP_NAMES[@]}"; do
    APP_SELECTIONS+=("FALSE" "$APP")
  done

  # Usa '--print-column=2' para que o yad retorne APENAS o nome do aplicativo
  SELECTION=$(yad --list \
    --title="Workspace $WS - Selecione aplicativos" \
    --text="Selecione os aplicativos para iniciar no workspace <b>$WS</b>:" \
    --width=700 --height=500 \
    --center \
    --multiple \
    --separator="|" \
    --print-column=2 \
    --column="✔":CHK --column="Aplicativo":TEXT \
    "${APP_SELECTIONS[@]}")

  # Verifica se o usuário pressionou "Cancelar" ou não selecionou nada
  if [[ $? -ne 0 || -z "$SELECTION" ]]; then
    continue
  fi

  # Processa a seleção do usuário
  IFS='|' read -ra SELECTED_APPS <<< "$SELECTION"
  for APP_NAME in "${SELECTED_APPS[@]}"; do
    if [[ -n "$APP_NAME" ]]; then # Garante que não processemos entradas vazias
      EXEC_CMD="${APP_COMMANDS[$APP_NAME]}"
      [[ -n "$EXEC_CMD" ]] && echo "$WS:$EXEC_CMD" >> "$CONFIG_FILE"
    fi
  done
done

yad --info --title="Configuração salva" --text="A configuração foi salva com sucesso em:\n<b>$CONFIG_FILE</b>"