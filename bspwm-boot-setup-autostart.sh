#!/bin/bash

# --- NOVO: CONFIGURAÇÃO DE LOG ---
# Define um arquivo de log na sua pasta home para fácil acesso.
LOG_FILE="$HOME/boot-setup.log"

# Limpa o log antigo e redireciona TODA a saída (normal e de erro) para o novo arquivo de log.
# A partir daqui, tudo que o script fizer ou qualquer erro que acontecer será gravado no arquivo.
exec >"$LOG_FILE" 2>&1

echo "--- Diário de Bordo do Boot Setup ---"
echo "Script iniciado em: $(date)"
echo "-------------------------------------"
echo

# --- Lógica de Espera (com mais logs) ---
echo "Procurando pelo bspwm..."
attempts=0
max_attempts=200 # Timeout de 20 segundos

# Usando o caminho completo para o bspc para máxima compatibilidade
while ! /usr/bin/bspc query -N -n; do
  attempts=$((attempts + 1))
  if [ "$attempts" -ge "$max_attempts" ]; then
    echo "ERRO: Timeout! O bspwm não respondeu após 20 segundos."
    notify-send "Boot Setup" "Erro: bspwm não respondeu a tempo."
    exit 1
  fi
  # Gravando a tentativa no log
  echo "Tentativa #$attempts... bspwm ainda não está pronto. Esperando 0.1s."
  sleep 0.1
done

echo "SUCESSO: bspwm está pronto e respondendo!"
echo

# --- Lógica Principal (com mais logs) ---
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/bspwm-boot-setup/config.txt"

echo "Lendo o arquivo de configuração em: $CONFIG_FILE"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERRO: Arquivo de configuração não encontrado. Saindo."
  exit 0
fi

echo "Conteúdo do arquivo de configuração:"
cat "$CONFIG_FILE"
echo "-------------------------------------"
echo

while IFS=: read -r ws app; do
  if [ -z "$ws" ] || [ -z "$app" ]; then
    echo "PULANDO linha malformada ou vazia."
    continue
  fi

  echo "EXECUTANDO: Trocando para o workspace '$ws'"
  /usr/bin/bspc desktop -f "$ws"
  
  echo "EXECUTANDO: Lançando o aplicativo '$app'"
  bash -c "$app &"
  
  sleep 1
done < "$CONFIG_FILE"

echo
echo "-------------------------------------"
echo "Script finalizado em: $(date)"
echo "--- Fim do Diário de Bordo ---"