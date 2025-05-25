#!/bin/bash
# Восстановление Frontend
cd ~/linux_project/frontend 
sudo cp nginx_lb.conf /etc/nginx/conf.d/
sudo chmod +x setup_frontend.sh
sudo ./setup_frontend.sh

# Восстановление Master
cd ~/linux_project/master  # Исправленный путь
sudo chmod +x setup_master.sh
sudo ./setup_master.sh

# Восстановление Slave
cd ~/linux_project/slave  # Исправленный путь
sudo cp mysql_backup.sh /usr/local/bin/  # Исправленный путь
sudo chmod +x /usr/local/bin/mysql_backup.sh
sudo chmod +x setup_slave.sh
sudo ./setup_slave.sh

# Создаем директорию для бэкапов
sudo mkdir -p /backups/mysql  # Добавленная строка

# Восстановление БД
LAST_BACKUP=$(sudo ls -t /backups/mysql/*.sql 2>/dev/null | head -n1)
if [ -n "$LAST_BACKUP" ]; then
    mysql -u root -pPassword123! test_db < "$LAST_BACKUP"
else
    echo "No backups found!"  # Уведомление если бэкапов нет
fi
