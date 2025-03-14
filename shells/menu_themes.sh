#!/bin/bash

########################################

MainMenu() {
    echo "Entering Main Menu loop..."
    local dialog_options=( 1 "Default" 2 "Souls" 3 "Pokemon" 4 "Theme 3" )

    while true; do
        current_time=$(date +%H:%M:%S)
        current_date=$(date +%F)
        current_zone=$(date +%Z)
        show_dialog=(dialog \
            --title "Themes Menu" \
            --clear \
            --cancel-label "Exit" \
            --menu "$current_date $current_time $current_zone" 0 0 0)

        choices=$("${show_dialog[@]}" "${dialog_options[@]}" 2>&1 > /dev/tty0) || userExit

        for choice in $choices; do
            case $choice in
            1) Default ;;
            2) Souls ;;
            3) Pokemon ;;
            4) Theme3 ;;
            esac
        done
        sleep 1
    done
}


########################################

Default() {

    echo ctheme=/roms/launchimages/gifs > /roms/launchimages/theme.txt
    
}

########################################

Souls() {

    echo ctheme=/roms/launchimages/gifs/souls > /roms/launchimages/theme.txt
    
}

########################################

Pokemon() {

    echo ctheme=/roms/launchimages/gifs/pokemon > /roms/launchimages/theme.txt
    
}

########################################

Theme3() {

    echo ctheme=/roms/launchimages/gifs/theme3 > /roms/launchimages/theme.txt
    
}

########################################

userExit() {
    echo "Exiting..."
    $ESUDO kill -9 $(pidof oga_controls)
    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    dialog --clear
    printf "\033c" > /dev/tty0
    exit 0
}

########################################

echo "Starting Main Menu..."
MainMenu
userExit

########################################
