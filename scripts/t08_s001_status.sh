#!/bin/bash


export MYSQL_PWD=Lvam2@*es*; mysql -uroot -e "show status like 'wsrep%';" > /tmp/wsrepout.txt

if [ "$1" = "wsrep_lsc" ]; then
     if [ -e /tmp/wsrepout.txt ]; then
       if cat /tmp/wsrepout.txt | grep -q "wsrep_local_state_comment    Synced"; then
       echo "OK"
       else
       echo "FAIL"
       fi
     else
     echo "NF"
     fi


elif [ "$1" = "wsrep_cw" ]; then
     if [ -e /tmp/wsrepout.txt ]; then
       if cat /tmp/wsrepout.txt | grep -q "wsrep_cluster_size   3"; then
       echo "OK"
       else
       echo "FAIL"
       fi
     else
     echo "NF"
     fi

elif [ "$1" = "wsrep_es" ]; then
     if [ -e /tmp/wsrepout.txt ]; then
       if cat /tmp/wsrepout.txt | grep -q "wsrep_evs_state      OPERATIONAL"; then
       echo "OK"
       else
       echo "FAIL"
       fi
     else
     echo "NF"
     fi

else
     echo "NF"
fi
