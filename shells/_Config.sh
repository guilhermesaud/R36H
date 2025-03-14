#!/bin/bash


# Copia Zukadote
sudo rm /opt/system/_Zukadote.sh
sudo cp -f /roms/shells/_Zukadote.sh /opt/system/_Zukadote.sh
sudo chmod 777 /opt/system/_Zukadote.sh


# Loading de jogos
sudo echo "#!/bin/bash" > /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh
sudo echo "/roms/shells/troca_loading.sh" >> /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh
sudo chmod 777 /home/ark/.emulationstation/scripts/game-start/run_troca_loading.sh
