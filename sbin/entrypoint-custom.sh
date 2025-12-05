#!/bin/bash

/usr/sbin/groupmod -g $MYSQL_GID mysql
/usr/sbin/usermod -u $MYSQL_UID -g $MYSQL_GID mysql
exec /usr/local/bin/docker-entrypoint.sh "$@"