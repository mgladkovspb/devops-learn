#! /bin/bash

NO_FORMAT="\033[0m"
C_GREEN="\033[38;5;2m"
C_RED="\033[38;5;196m"

exec_command() {
    echo -n "* $1 ... "
    error=`$2 2>&1`
    if [ $? -eq 0 ]; then
        echo -e "${C_GREEN}готово${NO_FORMAT}"
    else
        echo -e "${C_RED}ошибка${NO_FORMAT}"
        echo $error
    fi

    return $?
}

help_message() {
    echo "Использование скрипта: webbooks.sh [опции]"
    echo "Данный скрипт предназначен для запуска в Ubuntu"
    echo "  -i --install     Запуск установки"
    echo "  -h --help        Показать help"
}

main() {
    echo -e "${C_GREEN}WebBooks install script${NO_FORMAT}"

    {
        exec_command "Обновление базы пакетов" "apt update -y" &&
        exec_command "Обновление пакетов" "apt upgrade -y" &&
        exec_command "Установка Postgresql" "apt install postgresql -y" &&
        exec_command "Установка openjdk-17-jre" "apt install openjdk-17-jre -y" &&
        exec_command "Установка openjdk-17-jdk" "apt install openjdk-17-jdk -y"
    } || {
        exit $?
    }
    
    #echo -n "* Обновление пакетов ... "
    #{
    #    apt update
    #    apt upgrade -y
    #} &> /dev/null
    #echo -e "${C_GREEN}готово${NO_FORMAT}"

    #echo -n "* Установка Postgresql ... "
    #apt install postgresql -y &> /dev/null
    #echo -e "${C_GREEN}готово${NO_FORMAT}"

    #echo -n "* Установка jre / jdk ... "
    #{
    #    apt install openjdk-17-jre -y
    #    apt install openjdk-17-jdk -y
    #} &> /dev/null
    #echo -e "${C_GREEN}готово${NO_FORMAT}"
}

OPTIONS=$(getopt -o "i, h" -l "install, help" -- "$@")

if [[ $# -eq 0 ]]; then
    help_message
    exit 0
fi

eval set -- "$OPTIONS"

case "$1" in 
    -h|--help) help_message exit 0;;
    -i|--install) main exit 0;;
esac
