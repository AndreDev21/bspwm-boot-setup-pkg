#!/bin/bash

# Define o arquivo de configuração e o limpa no início
CONFIG="$HOME/projects/boot-setup/config.txt"
> "$CONFIG"

# Mapeia os aplicativos com base nos arquivos .desktop
# Usamos um array associativo para ligar o nome do app ao seu comando
declare -A APP_COMMANDS
while IFS= read -r file; do
  # Extrai o nome e o comando de execução do arquivo .desktop
  NAME=$(grep -m1 '^Name=' "$file" | cut -d= -f2)
  EXEC=$(grep -m1 '^Exec=' "$file" | cut -d= -f2 | sed 's/ %.*//') # Remove argumentos como %U, %f, etc.

  # Adiciona ao array apenas se ambos os campos existirem
  if [[ -n "$NAME" && -n "$EXEC" ]]; then
    APP_COMMANDS["$NAME"]="$EXEC"
  fi
done < <(find /usr/share/applications ~/.local/share/applications -name '*.desktop' -print 2>/dev/null)

# --- CORREÇÃO 1: Criar o array de nomes de forma segura ---
# Usa 'mapfile' (ou 'readarray') para ler cada linha da saída em um elemento do array.
# Isso preserva nomes com espaços, como "Visual Studio Code".
mapfile -t APP_NAMES < <(printf "%s\n" "${!APP_COMMANDS[@]}" | sort)

# Lista de workspaces detectados pelo bspwm
WORKSPACES=$(bspc query -D --names | sort -n)

# Itera sobre cada workspace para o usuário selecionar os aplicativos
for WS in $WORKSPACES; do
  # Prepara o array de seleções para o yad
  APP_SELECTIONS=()
  for APP in "${APP_NAMES[@]}"; do
    APP_SELECTIONS+=("FALSE" "$APP")
  done

  # --- CORREÇÃO 2: Simplificar a saída do yad ---
  # Adicionamos '--print-column=2' para que o yad retorne APENAS o nome do aplicativo
  # (o conteúdo da segunda coluna), e não "TRUE|Nome do Aplicativo|".
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

  # Verifica se o usuário pressionou "Cancelar" (código de saída != 0) ou não selecionou nada
  if [[ $? -ne 0 || -z "$SELECTION" ]]; then
    continue
  fi

  # Processa a seleção do usuário
  # A variável IFS (Internal Field Separator) é modificada apenas para o comando 'read'
  IFS='|' read -ra SELECTED_APPS <<< "$SELECTION"
  for APP_NAME in "${SELECTED_APPS[@]}"; do
    # O loop 'for' lida bem com os nomes, mesmo que contenham espaços
    if [[ -n "$APP_NAME" ]]; then # Garante que não processemos entradas vazias
      EXEC_CMD="${APP_COMMANDS[$APP_NAME]}"
      [[ -n "$EXEC_CMD" ]] && echo "$WS:$EXEC_CMD" >> "$CONFIG"
    fi
  done
done

# Notifica o usuário que a configuração foi salva
yad --info --title="Configuração salva" --text="A configuração foi salva com sucesso em:\n<b>$CONFIG</b>"