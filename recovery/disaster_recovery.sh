#!/bin/bash
# Восстанавливаем Frontend
git clone https://github.com/your_username/linux_project.git
cd linux_project/frontend
sudo chmod +x setup_frontend.sh
./setup_frontend.sh

# Восстанавливаем Master
cd ../master
sudo chmod +x setup_master.sh
./setup_master.sh

# Восстанавливаем Slave
cd ../slave
sudo chmod +x setup_slave.sh
./setup_slave.sh

# Восстановление БД из последнего бэкапа (если нужно)
LAST_BACKUP=$(ls -t /backups/mysql/*.sql | head -n1)
mysql -u root -pPassword123! test_db < $LAST_BACKUP
