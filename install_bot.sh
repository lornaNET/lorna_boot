#!/bin/bash

# Clear screen and define colors
clear
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

draw_menu() {
    clear
    echo ""
    echo -e "${BLUE}${BOLD}==============================${RESET}"
    echo -e "${YELLOW}${BOLD}        LORNA INSTALLER       ${RESET}"
    echo -e "${BLUE}${BOLD}==============================${RESET}"
    echo ""
    echo -e "${GREEN}[1] Install Certbot${RESET}     ${RED}[2] Install Nginx${RESET}"
    echo -e "${YELLOW}[3] Install MySQL${RESET}     ${CYAN}[4] Install phpMyAdmin${RESET}"
    echo -e "${MAGENTA}[5] Exit${RESET}"
    echo ""
}

# Draw the menu
draw_menu

# Read user input
read -p "Choose an option [1-5]: " CHOICE

# Perform actions based on user choice
case "$CHOICE" in
    1)
        echo -e "${GREEN}Installing Certbot...${RESET}"
        # Install Certbot
        sudo apt install certbot python3-certbot-nginx -y
        echo -e "${GREEN}Certbot installation complete!${RESET}"
        ;;
    2)
        echo -e "${RED}Installing Nginx...${RESET}"
        # Install Nginx
        sudo apt install nginx -y
        echo -e "${RED}Nginx installation complete!${RESET}"
        ;;
    3)
        echo -e "${YELLOW}Installing MySQL...${RESET}"
        # Install MySQL
        sudo apt install mysql-server -y
        sudo mysql_secure_installation
        echo -e "${YELLOW}MySQL installation complete!${RESET}"
        ;;
    4)
        echo -e "${CYAN}Installing phpMyAdmin...${RESET}"
        # Install phpMyAdmin
        sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
        sudo systemctl restart apache2
        echo -e "${CYAN}phpMyAdmin installation complete!${RESET}"
        ;;
    5)
        echo -e "${MAGENTA}Goodbye!${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice! Please choose a valid option.${RESET}"
        ;;
esac
