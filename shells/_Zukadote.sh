#!/bin/bash

# Determinando pasta de controle
if [ -d "/opt/system/Tools/PortMaster/" ]; then
    controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
    controlfolder="/opt/tools/PortMaster"
else
    controlfolder="/roms/ports/PortMaster"
fi

# Importando configuracoes
source "$controlfolder/control.txt" > /dev/null 2>&1
get_controls > /dev/null 2>&1

cd "$controlfolder" > /dev/null 2>&1

# Definindo permissoes sem exibir mensagens
$ESUDO chmod 666 /dev/uinput > /dev/null 2>&1
$ESUDO $controlfolder/oga_controls calendar.sh $param_device > /dev/null 2>&1 &

export TERM=linux
LANG=""

$ESUDO chmod 666 /dev/tty0 > /dev/null 2>&1
printf "\033c" > /dev/tty0
dialog --clear > /dev/null 2>&1

sudo chmod 666 /dev/tty1 > /dev/null 2>&1
reset > /dev/null 2>&1

# Escondendo cursor
printf "\e[?25l" > /dev/tty1
dialog --clear > /dev/null 2>&1

# Configuracao do tamanho do menu
height="15"
width="55"

if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"; then
  height="20"
  width="60"
fi

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

# Definicao de fonte baseada no dispositivo
if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"; then
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold20x10.psf.gz > /dev/null 2>&1
  else
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz > /dev/null 2>&1
  fi
else
  sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz > /dev/null 2>&1
fi



########################################

GetWifiStatus() {
    # Verifica se o Wi-Fi esta ligado ou desligado
    if nmcli radio wifi | grep -q "enabled"; then
        wifi_status="\Z2[ON]\Zn"
        # Obtem o nome da rede Wi-Fi conectada
        wifi_network="\Zb\Z4$(nmcli -t -f name,device connection show --active | grep wlan0 | cut -d':' -f1)\Zn"
        if [[ -z "$wifi_network" ]]; then
            wifi_network=" "
        fi
    else
        wifi_status="\Z1[OFF]\Zn"
        wifi_network=" "
    fi
}

########################################

MainMenu() {
    #echo "Entering Main Menu loop..."

    while true; do
        GetWifiStatus
        local dialog_options=( 
          1 "WIFI ON/OFF" 
          2 "Backup" 
          3 "Restaurar" 
          4 "Temas" 
          5 "Atualiza Zukadote" 
          99 "Exit"
        )

        current_time=$(date +%H:%M)
        current_date=$(date +%d/%m/%Y)

        show_dialog=(dialog \
            --title "ZUKADOTE" \
            --clear \
            --colors \
            --cancel-label "Exit" \
            --menu "\Zb\Z4$current_date\Zn     \Z0|\Zn     \Z4$current_time\Zn     \Z0|\Zn $wifi_status $wifi_network" 15 40 15)

        choices=$("${show_dialog[@]}" "${dialog_options[@]}" 2>&1 > /dev/tty0) || userExit

        for choice in $choices; do
            case $choice in
            1) ToggleWifi ;;
            2) Backup ;;
            3) Restaurar ;;
            4) Temas ;;
            5) UpdateZukadote ;;
            99) userExit ;;
            esac
        done
        sleep 1
    done
}

########################################

ToggleWifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

########################################

Backup() {
    bash /roms/shells/bkp.sh
}

########################################

Restaurar() {
    bash /roms/shells/restaura.sh
}

########################################

UpdateZukadote() {
    bash /roms/shells/_Config.sh
}

########################################

Temas() {
    bash /roms/shells/menu_themes.sh
}

########################################

userExit() {
    #echo "Exiting..."
    $ESUDO kill -9 $(pidof oga_controls)
    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    dialog --clear
    printf "\033c" > /dev/tty0
    exit 0
}

########################################

#echo "Starting Main Menu..."
MainMenu
userExit

########################################
