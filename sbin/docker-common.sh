#!/bin/bash

if [ -e /local/mysql/tag.txt ]; then
  TAG=$(cat /local/mysql/tag.txt)
else
  TAG=$(cat /local/mysql/defaults/tag.txt)
fi

ARGS=""
ARGS="-v /local/mysql:/local/mysql"

# For PID
mkdir -p /var/run/mysql
chown mysql:mysql /var/run/mysqld
ARGS="$ARGS -v /var/run/mysqld:/var/run/mysqld"

# Root connection parameters
touch /root/.my.cnf
chown root:root /root/.my.cnf
ARGS="$ARGS -v /root/.my.cnf:/root/.my.cnf"

# For connection socket
mkdir -p /var/run/mysql
chown mysql:mysql /var/run/mysql
ARGS="$ARGS -v /var/run/mysql:/var/run/mysql"

# Make sure to pass in timezone from host
ARGS="$ARGS -v /etc/localtime:/etc/localtime"

# Allow bootstrapping
ARGS="$ARGS -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1"

# Limits
ARGS="$ARGS --ulimit nofile=16000:16000"

# Customize entrypoint and environment variables
ARGS="$ARGS --entrypoint /local/mysql/sbin/entrypoint-custom.sh"
ARGS="$ARGS -e MYSQL_UID=$(id -u mysql)"
ARGS="$ARGS -e MYSQL_GID=$(id -g mysql)"
