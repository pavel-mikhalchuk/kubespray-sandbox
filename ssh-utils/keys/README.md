# Генерация SSH ключей

ssh-keygen

# Копировани SSH ключей на виртуалки (запуск от текущего пользователя)

ssh-copy-id -i ~/.ssh/id_rsa.pub <ip-address>

# Скрипт для копирования SSH ключей на несколько виртуалок

./copy-ssh-keys.sh
