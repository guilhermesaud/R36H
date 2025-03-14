#!/bin/bash

#
source /roms/launchimages/theme.txt

# Diretório de origem com as imagens
SOURCE_DIR="$ctheme"

# Arquivo de destino no diretório launchimages
DEST_FILE="/roms/launchimages/loading.gif"

# Verifica se o diretório de origem existe
if [ -d "$SOURCE_DIR" ]; then
  # Seleciona uma imagem aleatória do diretório
  RANDOM_IMAGE=$(find "$SOURCE_DIR" -type f -iname "*.gif" | shuf -n 1)
  
  # Verifica se uma imagem foi encontrada
  if [ -n "$RANDOM_IMAGE" ]; then
    # Copia e renomeia a imagem para o destino
    cp "$RANDOM_IMAGE" "$DEST_FILE"
    echo "Imagem '$RANDOM_IMAGE' copiada para '$DEST_FILE'."
  else
    echo "Nenhuma imagem válida encontrada em '$SOURCE_DIR'."
  fi
else
  echo "Diretório de origem '$SOURCE_DIR' não existe."
fi