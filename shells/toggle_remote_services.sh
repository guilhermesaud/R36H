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
        echo "Desativando servicos remotos..."
        sudo systemctl disable NetworkManager-wait-online
        sudo systemctl stop NetworkManager-wait-online
        sudo timedatectl set-ntp 0
        sudo systemctl stop smbd
        sudo systemctl stop nmbd
        sudo systemctl stop ssh.service
        sudo pkill filebrowser
        echo "Servicos remotos desativados."
    }
else 
    {
        sudo systemctl enable NetworkManager-wait-online
        sudo systemctl start NetworkManager-wait-online
        GW=`ip route | awk '/default/ { print $3 }'`
        if [ ! -z "$GW" ]; then
          echo "Ativando servicos remotos..."
          sudo timedatectl set-ntp 1 &
          sudo systemctl start smbd
          sudo systemctl start nmbd
          sudo systemctl start ssh.service
          sudo filebrowser -a 0.0.0.0 -p 80 -d /home/ark/.config/filebrowser.db -r / &
          echo "SUCESSO!"
          echo "IP: $(hostname -I | awk '{print $1}')"
          sleep 2
        else
          echo "ERRO: Conexao de rede nao detectada!"
          echo "Verifique sua rede Wi-Fi e tente novamente."
          sleep 2
        fi
    } 
fi