#! /bin/bash

NO_FORMAT="\033[0m"
C_GREEN="\033[38;5;2m"
C_RED="\033[38;5;196m"
C_YELLOW="\033[38;5;11m"

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

run_step() {
    echo -n "* $1 ... "
    error=`$2 2>&1`
    
    if [ $? -eq 0 ]; then
        echo -e "${C_GREEN}готово${NO_FORMAT}"
    else
        echo -e "${C_RED}ошибка${NO_FORMAT}"
        echo $error
        exit 1
    fi

    return $?
}

help_message() {
    echo "Использование скрипта: webbooks.sh [опции]"
    echo "Данный скрипт предназначен для запуска в Ubuntu"
    echo "  -i --install     Запуск установки"
    echo "  -h --help        Показать help"
}

install_pg() {
    run_step "Установка Postgresql" "apt install postgresql -y"
    psql -U postgres -c "alter user postgres with password '111';" &>/dev/null
}

install_nginx() {
    run_step "Установка Nginx" "apt install nginx -y"
    cp /mnt/d/projects/devops-learn/lesson8/webbook/webbook.nginx.conf /etc/nginx/sites-available/webbook.conf
    ln -s /etc/nginx/sites-available/webbook.conf /etc/nginx/sites-enabled &>/dev/null
}

install_webbooks() {
    run_step "Эмитация загрузки webbooks" "cp /mnt/d/projects/tmp/2025-02-example-main.zip ${USER_HOME}"
    run_step "Распаковка webbooks" "unzip ${USER_HOME}/2025-02-example-main.zip -d ${USER_HOME}" 
    
    mv ${USER_HOME}/2025-02-example-main/apps/webbooks ${USER_HOME}/webbooks &>/dev/null
    rm -rf ${USER_HOME}/2025-02-example-main &>/dev/null

    WEBBOOKS_USER="webbook"
    getent passwd $WEBBOOKS_USER > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        run_step "Создание пользователя $WEBBOOKS_USER" "adduser --disabled-password --gecos "" $WEBBOOKS_USER"
    fi

    echo -n "* Инициализация базы данных WebBooks ... "
    DB_NAME="webbooks"
    DB_EXISTS=$(psql -U postgres -tAc "select 1 from pg_database where datname='${DB_NAME}'")
    if [ "${DB_EXISTS}" != "1" ]; then
        createdb -U postgres ${DB_NAME}
    else
        dropdb -U postgres ${DB_NAME}
        createdb -U postgres ${DB_NAME}
    fi
    echo -e "${C_GREEN}готово${NO_FORMAT}"

    cd ${USER_HOME}
    echo -e "${C_YELLOW}* Применение миграций *${NO_FORMAT}"
    /usr/local/bin/flyway -configFiles="${USER_HOME}/flyway/flyway.toml" migrate

    cp /mnt/d/projects/devops-learn/lesson8/webbook/application.properties ${USER_HOME}/webbooks/src/main/resources
    cd "${USER_HOME}/webbooks"
    chmod +x mvnw
    run_step "Сборка webbooks" "./mvnw package"
    run_step "Перенос службы в рабочий каталог" "cp -r ${USER_HOME}/webbooks /opt"

    chown ${WEBBOOKS_USER}:${WEBBOOKS_USER} -R /opt/webbooks

    run_step "Регистрация службы webbooks" "cp /mnt/d/projects/devops-learn/lesson8/webbook/webbook.service /etc/systemd/system"
}

install_flyway() {
    run_step "Эмитация загрузки flyway" "cp /mnt/d/projects/tmp/flyway-commandline-11.3.4-linux-x64.tar.gz ${USER_HOME}" #"wget -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/11.3.4/flyway-commandline-11.3.4-linux-x64.tar.gz"
    run_step "Установка flyway" "tar -xzf ${USER_HOME}/flyway-commandline-11.3.4-linux-x64.tar.gz -C /opt"
    ln -s /opt/flyway-11.3.4/flyway /usr/local/bin &>/dev/null
    cp -r /mnt/d/projects/devops-learn/lesson8/flyway ${USER_HOME}
}

main() {
    echo -e "${C_GREEN}WebBooks install script${NO_FORMAT}"

    #echo $USER_HOME
    cd $USER_HOME

    run_step "Обновление базы пакетов" "apt update -y"
    run_step "Обновление пакетов" "apt upgrade -y"

    run_step "Установка openjdk-17-jre" "apt install openjdk-17-jre -y"
    run_step "Установка openjdk-17-jdk" "apt install openjdk-17-jdk -y"

    install_pg
    install_nginx
    install_flyway
    install_webbooks

    run_step "Загрузка конфигурации служб" "systemctl daemon-reload"
    run_step "Запуск Postgresql" "systemctl restart postgresql.service"
    run_step "Запуск Nginx" "systemctl restart nginx.service"
    run_step "Запуск webbook" "systemctl start webbook.service"
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
