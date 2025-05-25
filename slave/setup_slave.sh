#!/bin/bash
# Установка MySQL
sudo apt update
sudo apt install -y mysql-server

# Конфиг MySQL Slave
sudo bash -c 'cat <<EOF > /etc/mysql/mysql.conf.d/replication.cnf
[mysqld]
server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log
EOF'

# Перезапуск MySQL
sudo systemctl restart mysql

# Запуск репликации
sudo mysql -e "CHANGE MASTER TO
MASTER_HOST='192.168.1.10',
MASTER_USER='replica_user',
MASTER_PASSWORD='Password123!',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=154;
START SLAVE;"

# Установка Loki
wget https://github.com/grafana/loki/releases/download/v2.4.2/loki-linux-amd64.zip
unzip loki-*.zip
./loki-linux-amd64 -config.file=loki-config.yaml &

# Установка Promtail
wget https://github.com/grafana/loki/releases/download/v2.4.2/promtail-linux-amd64.zip
unzip promtail-*.zip
./promtail-linux-amd64 -config.file=promtail-config.yaml &

# Копируем скрипт бэкапа
sudo cp /путь/до/репозитория/slave/mysql_backup.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/mysql_backup.sh

# Добавляем в Cron
(crontab -l ; echo "0 3 * * * /usr/local/bin/mysql_backup.sh") | crontab -
