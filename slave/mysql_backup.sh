#!/bin/bash
BACKUP_DIR="/backups/mysql"
MYSQL_USER="root"
MYSQL_PASS="Password123!"
DATABASE="test_db"

# Создаем директорию для бэкапов
mkdir -p $BACKUP_DIR

# Список таблиц
TABLES=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e "USE $DATABASE; SHOW TABLES;" | grep -v 'Tables_in')

# Бэкап каждой таблицы
for TABLE in $TABLES; do
    mysqldump -u$MYSQL_USER -p$MYSQL_PASS $DATABASE $TABLE > "$BACKUP_DIR/${TABLE}_$(date +%Y%m%d).sql"
done

# Сохраняем позицию бинарного лога
mysql -u$MYSQL_USER -p$MYSQL_PASS -e "SHOW SLAVE STATUS\G" > "$BACKUP_DIR/binlog_status_$(date +%Y%m%d).txt"
