#!/bin/bash
CURR_TTY="/dev/tty1"
sudo chmod 666 $CURR_TTY

# Define o diretorio base para os backups
BACKUP_DIR="/roms/backup/zukadote"

# Cria o nome do diretorio de backup com base na data e hora atual
TIMESTAMP=$(date +"%Y%m%d_%H_%M_%S")
DEST_DIR="$BACKUP_DIR/bkp_$TIMESTAMP"

# Lista de arquivos e diretorios para backup
FILES=(
    "/etc/emulationstation/es_systems.cfg"
    "/home/ark/.emulationstation/es_settings.cfg"
    "/home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh"
    "/home/ark/.emulationstation/collections"
    "/home/ark/.config/retroarch/retroarch.cfg"
    "/home/ark/.config/retroarch/config"
    "/opt/cmds/gamelist.xml"
    "/opt/cmds/r32.png"
    "/opt/cmds/r64.png"
    "/opt/system/gamelist.xml"
    "/opt/system/Zukadote.sh"
    "/opt/system/Zukadote.png"
    "/usr/bin/emulationstation/resources/splash.svg"
    "/usr/bin/emulationstation/resources/battery/25.svg"
    "/usr/bin/emulationstation/resources/battery/50.svg"
    "/usr/bin/emulationstation/resources/battery/75.svg"
    "/usr/bin/emulationstation/resources/battery/empty.svg"
    "/usr/bin/emulationstation/resources/battery/full.svg"
    "/usr/bin/emulationstation/resources/battery/incharge.svg"
    "/usr/bin/emulationstation/resources/locale/br/emulationstation2.po"
    "/roms/shells/
    "/roms/retroarch/"
    "/roms/arcade/gamelist.xml"
    "/roms/dreamcast/gamelist.xml"
    "/roms/gamegear/gamelist.xml"
    "/roms/gb/gamelist.xml"
    "/roms/gba/gamelist.xml"
    "/roms/gbc/gamelist.xml"
    "/roms/j2me/gamelist.xml"
    "/roms/mastersystem/gamelist.xml"
    "/roms/megadrive/gamelist.xml"
    "/roms/n64/gamelist.xml"
    "/roms/nds/gamelist.xml"
    "/roms/neogeo/gamelist.xml"
    "/roms/nes/gamelist.xml"
    "/roms/ngpc/gamelist.xml"
    "/roms/pcengine/gamelist.xml"
    "/roms/pico-8/carts/gamelist.xml"
    "/roms/ports/gamelist.xml"
    "/roms/psp/gamelist.xml"
    "/roms/psx/gamelist.xml"
    "/roms/saturn/gamelist.xml"
    "/roms/scummvm/gamelist.xml"
    "/roms/segacd/gamelist.xml"
    "/roms/snes/gamelist.xml"
    "/roms/wonderswancolor/gamelist.xml"
)

# Cria o diretorio de destino
mkdir -p "$DEST_DIR"

# Funcao para copiar arquivos mantendo a estrutura de diretorios
copy_with_structure() {
    local src="$1"
    local dest_base="$2"

    if [ -f "$src" ]; then
        local relative_path="${src#/}"
        local dest_dir="$dest_base/$(dirname "$relative_path")"
        mkdir -p "$dest_dir"
        cp "$src" "$dest_dir/"
    elif [ -d "$src" ]; then
        local relative_path="${src#/}"
        local dest_dir="$dest_base/$relative_path"
        mkdir -p "$dest_dir"
        cp -r "$src/." "$dest_dir/"
    else
        echo "AVISO! Arquivo ou diretorio nao encontrado: $src"
    fi
}

# Total de arquivos para backup
TOTAL_FILES=${#FILES[@]}
CURRENT_PROGRESS=0

# Inicia a barra de progresso
(
for item in "${FILES[@]}"; do
    copy_with_structure "$item" "$DEST_DIR"
    CURRENT_PROGRESS=$((CURRENT_PROGRESS + 1))
    PERCENTAGE=$((CURRENT_PROGRESS * 100 / TOTAL_FILES))
    echo "$PERCENTAGE"
    sleep 0.1  # Pequena pausa para a barra de progresso ser visivel
done
) | dialog --gauge "Realizando backup, aguarde..." 7 50 0 > "$CURR_TTY"

# Mensagem de conclusao
dialog --msgbox "Backup concluido com sucesso em: $DEST_DIR" 7 50 > "$CURR_TTY"
