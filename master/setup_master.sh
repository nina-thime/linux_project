#!/bin/bash
# Установка MySQL
sudo apt update
sudo apt install -y mysql-server

# Конфиг MySQL Master
sudo bash -c 'cat <<EOF > /etc/mysql/mysql.conf.d/replication.cnf
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = test_db
bind-address = 0.0.0.0
EOF'

# Перезапуск MySQL
sudo systemctl restart mysql

# Создание пользователя репликации
sudo mysql -e "CREATE USER 'replica_user'@'%' IDENTIFIED BY 'Password123!';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Установка Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
tar -xvf prometheus-*.tar.gz
cd prometheus-*/
./prometheus --config.file=prometheus.yml &

# Установка Grafana
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update && sudo apt-get install -y grafana
sudo systemctl start grafana-server
