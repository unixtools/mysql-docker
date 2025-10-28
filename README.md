mysql
=====

Ubuntu:
adduser --disabled-password --home=/local/mysql --no-create-home --shell=/bin/bash --gecos=mysql mysql
./setup-local-dirs

For binlog support, add to mysql.conf (tune as needed):

log_bin=/local/mysql/binlogs/log
binlog_format=ROW
server_id=1
expire-logs-days = 3
max-binlog-size = 500M



Quick create new database:

create database userid character set utf8 collate utf8_bin;
grant all on userid.* to userid@'%' identified by 'xxx';
grant all on userid.* to userid@localhost identified by 'xxx';

