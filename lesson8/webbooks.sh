#! /bin/bash

NO_FORMAT="\033[0m"
C_GREEN="\033[38;5;2m"

help_message() {
    echo "Использование скрипта: webbooks.sh [опции]"
    echo "  -i --install     Запуск установки"
    echo "  -h --help        Показать help"
}

install() {
    echo -e "${C_GREEN}WebBooks install script${NO_FORMAT}"

    echo -n "* Обновление пакетов ... "
    {
        apt update
        apt upgrade -y
    } &> /dev/null
    echo -e "${C_GREEN}готово${NO_FORMAT}"

    echo -n "* Установка Postgresql ... "
    apt install postgresql -y &> /dev/null
    echo -e "${C_GREEN}готово${NO_FORMAT}"

    echo -n "* Установка jre / jdk ... "
    {
        apt install openjdk-17-jre -y
        apt install openjdk-17-jdk -y
    } &> /dev/null
    echo -e "${C_GREEN}готово${NO_FORMAT}"
}

OPTIONS=$(getopt -o "i, h" -l "install, help" -- "$@")

if [[ $# -eq 0 ]]; then
    help_message
    exit 0
fi

eval set -- "$OPTIONS"


case "$1" in 
    -h|--help) help_message exit 0;;
    -i|--install) install exit 0;;
esac
