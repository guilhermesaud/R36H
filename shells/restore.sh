#!/bin/bash

# Diret�rio base dos backups dispon�veis
BACKUP_DIR="/roms/backup/zukadote"

# Fun��o para listar as pastas dispon�veis e permitir a sele��o
select_backup_folder() {
    local options=()
    
    # Ordena as pastas por data de modifica��o (mais recente primeiro)
    for folder in $(ls -td "$BACKUP_DIR"/*/); do
        folder_name=$(basename "$folder")
        options+=("$folder_name" "")
    done

    chosen_folder=$(dialog \
        --title "BACKUP" \
        --menu "Escolha um backup:" 15 40 15 \
        "${options[@]}" 2>&1 > /dev/tty0) || exit 1

    echo "$BACKUP_DIR/$chosen_folder"
}

# Seleciona a pasta de backup
RESTORE_DIR=$(select_backup_folder)
BACKUP_NAME=$(basename "$RESTORE_DIR")

# Verifica se a pasta foi selecionada
if [ -z "$RESTORE_DIR" ]; then
    exit 1
fi

# Arquivo tempor�rio para exibi��o no dialog
TEMP_FILE="/tmp/restore_progress"
echo "Restaurando arquivos..." > "$TEMP_FILE"

# Abre o dialog em um processo em background
( tail -f "$TEMP_FILE" | dialog --title "Restaurando" --programbox 18 50 ) &
DIALOG_PID=$!

# Fun��o para restaurar arquivos mantendo a estrutura original
restore_file_with_structure() {
    local src_file="$1"
    local relative_path="${src_file#$RESTORE_DIR/}"
    local dest_file="/$relative_path"

    # Copia o arquivo para o local original
    sudo cp -f "$src_file" "$dest_file"
    echo "$dest_file" >> "$TEMP_FILE"
}

# Loop para restaurar todos os arquivos do diret�rio de restaura��o
find "$RESTORE_DIR" -type f | while read -r file; do
    restore_file_with_structure "$file"
done

# Finaliza o dialog
sleep 1
kill $DIALOG_PID
rm -f "$TEMP_FILE"

# Mensagem de conclus�o
dialog --title "Concluido" --msgbox "Restauracao concluida com sucesso! \nBackup: $BACKUP_NAME" 6 50
