#!/bin/bash
# Полный путь к репозиторию (замените nina-thime на ваш логин)
REPO_PATH="$HOME/linux_project"
GIT_USER="nina-thime"

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

# Создаем директорию для бэкапов
sudo mkdir -p /backups/mysql
sudo chown -R mysql:mysql /backups/mysql

# Установка Loki
wget https://github.com/grafana/loki/releases/download/v2.4.2/loki-linux-amd64.zip || { echo "Ошибка загрузки Loki"; exit 1; }
unzip loki-linux-amd64.zip -d ./loki || { echo "Ошибка распаковки Loki"; exit 1; }
sudo mv ./loki/loki-linux-amd64 /usr/local/bin/loki
sudo chmod +x /usr/local/bin/loki

# Установка Promtail
wget https://github.com/grafana/loki/releases/download/v2.4.2/promtail-linux-amd64.zip || { echo "Ошибка загрузки Promtail"; exit 1; }
unzip promtail-linux-amd64.zip -d ./promtail || { echo "Ошибка распаковки Promtail"; exit 1; }
sudo mv ./promtail/promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

# Копируем файлы конфигурации и скрипты
sudo cp "$REPO_PATH/slave/loki-config.yaml" /etc/loki-config.yaml
sudo cp "$REPO_PATH/slave/promtail-config.yaml" /etc/promtail-config.yaml
sudo cp "$REPO_PATH/slave/mysql_backup.sh" /usr/local/bin/
sudo chmod +x /usr/local/bin/mysql_backup.sh

# Настройка сервисов
# Создаем сервис для Loki
sudo bash -c 'cat <<EOF > /etc/systemd/system/loki.service
[Unit]
Description=Loki service
After=network.target

[Service]
ExecStart=/usr/local/bin/loki -config.file=/etc/loki-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Создаем сервис для Promtail
sudo bash -c 'cat <<EOF > /etc/systemd/system/promtail.service
[Unit]
Description=Promtail service
After=network.target

[Service]
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Запуск сервисов
sudo systemctl daemon-reload
sudo systemctl enable loki promtail
sudo systemctl start loki promtail

# Настройка Cron
if ! crontab -l | grep -q "mysql_backup.sh"; then
    (crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/mysql_backup.sh") | crontab -
fi

echo "Настройка Slave завершена!"
