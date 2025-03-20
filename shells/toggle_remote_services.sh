#!/bin/bash

CheckRemoteServices() {
    if systemctl is-active --quiet smbd || \
       systemctl is-active --quiet nmbd || \
       systemctl is-active --quiet ssh || \
       pgrep filebrowser > /dev/null; then
        return 0
    else
        return 1
    fi
}

CheckRemoteServices
if [ $? -eq 0 ]; then
    {
        sudo systemctl disable NetworkManager-wait-online
        sudo systemctl stop NetworkManager-wait-online
        sudo timedatectl set-ntp 0
        sudo systemctl stop smbd
        sudo systemctl stop nmbd
        sudo systemctl stop ssh.service
        sudo pkill filebrowser
        dialog --msgbox "Servicos remotos desativados." 6 40
    }
else 
    {
        sudo systemctl enable NetworkManager-wait-online
        sudo systemctl start NetworkManager-wait-online
        GW=`ip route | awk '/default/ { print $3 }'`
        if [ ! -z "$GW" ]; then
          sudo timedatectl set-ntp 1 &
          sudo systemctl start smbd
          sudo systemctl start nmbd
          sudo systemctl start ssh.service
          sudo filebrowser -a 0.0.0.0 -p 80 -d /home/ark/.config/filebrowser.db -r / > /dev/null 2>&1 &
          IP=$(hostname -I | awk '{print $1}')
          dialog --msgbox "Servicos remotos ativados!\nIP: $IP" 6 40
        else
          dialog --msgbox "ERRO: Conexao de rede nao detectada!\nVerifique sua rede Wi-Fi e tente novamente."
        fi
    } 
fi