#!/bin/bash

GAMELIST="/opt/system/gamelist.xml"
GAME_ENTRY="<path>./Zukadote.sh</path>"
NEW_GAME="\
    <game>\n        <path>./Zukadote.sh</path>\n        <name>Zukadote</name>\n        <image>./Zukadote.png</image>\n        <desc>github.com/guilhermesaud/R36H</desc>\n    </game>\n"

# Verifica se a entrada já existe no gamelist.xml
if ! grep -q "$GAME_ENTRY" "$GAMELIST"; then
    # Adiciona a entrada ao final do arquivo antes da tag de fechamento </gameList>
    sudo sed -i "s|</gameList>|$NEW_GAME</gameList>|" "$GAMELIST"
fi

# Copia Zukadote
sudo rm -f /opt/system/Zukadote.sh
sudo cp -f /roms/shells/Zukadote.sh /opt/system/Zukadote.sh
sudo chmod 777 /opt/system/Zukadote.sh
sudo chown ark:ark /opt/system/Zukadote.sh

# Loading de jogos
sudo bash -c "echo '#!/bin/bash' > /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh"
sudo bash -c "echo '/roms/shells/troca_loading.sh' >> /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh"
sudo chmod 777 /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh
