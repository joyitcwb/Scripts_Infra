#!/usr/bin/env bash

# Mostra o estado do nó do MySQL Cluster
export MYSQL_PWD=Lvam2@*es*; mysql -uroot -e "show status like 'wsrep%';" | grep "wsrep_local_state_comment" | sed 's/\s\+/ /g' | cut -d' ' -f2
