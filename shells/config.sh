#!/bin/bash


# Verifica se a entrada ja existe no gamelist.xml
GAMELIST="/opt/system/gamelist.xml"
GAME_ENTRY="<path>./Zukadote.sh</path>"
NEW_GAME="\
    <game>\n        <path>./Zukadote.sh</path>\n        <name>Zukadote</name>\n        <image>./Zukadote.png</image>\n        <desc>github.com/guilhermesaud/R36H</desc>\n    </game>\n"

if ! grep -q "$GAME_ENTRY" "$GAMELIST"; then
    # Adiciona a entrada ao final do arquivo antes da tag de fechamento </gameList>
    sudo sed -i "s|</gameList>|$NEW_GAME</gameList>|" "$GAMELIST"
fi


# Loading de jogos
sudo bash -c "echo '#!/bin/bash' > /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh"
sudo bash -c "echo '/roms/shells/troca_loading.sh' >> /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh"
sudo chmod 777 /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh


#Cria Link Simbolico Zukadote
sudo ln -s /roms/shells/Zukadote.sh /opt/system/Zukadote.sh
sudo ln -s /roms/shells/Zukadote.png /opt/system/Zukadote.png

