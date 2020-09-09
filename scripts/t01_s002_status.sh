#!/bin/bash


DATA_YST=`date +%Y-%m-%d -d "-1 day"`
DATA_NOW=`date +%Y-%m-%d`
   
   if [ "$1" = "mysql" ]; then   
   	if  cat /joy/backup/mysql/xtrabackup.log | grep $DATA_NOW | grep -q "Backup Done"  ; then
   	echo "OK"
   	elif cat /joy/backup/mysql/xtrabackup.log | grep $DATA_YST | grep -q "Backup Done"  ; then
   	echo "OK"
   	else
   	echo "FAIL"
   	fi

   elif [ "$1" = "otrs" ]; then
        if  ls /joy/backup/otrs | grep -q $DATA_NOW ; then
        echo "OK"
        elif ls /joy/backup/otrs | grep -q $DATA_YST ; then
        echo "OK"
        else
        echo "FAIL"
        fi

   elif [ "$1" = "hestia" ]; then
        if  ls /joy/backup/hestia | grep -q $DATA_NOW ; then
        echo "OK"
        elif ls /joy/backup/hestia | grep -q $DATA_YST ; then
        echo "OK"
        else
        echo "FAIL"
        fi

   elif [ "$1" = "zimbra" ]; then
        DATA_YST=`date +%Y%m%d -d "-1 day"`
        DATA_NOW=`date +%Y%m%d` 
        if  ls /joy/backup/zimbra | grep -q $DATA_NOW ; then
        echo "OK"
        elif ls /joy/backup/zimbra | grep -q $DATA_YST ; then
        echo "OK"
        else
	echo "FAIL"
        fi

   elif [ "$1" = "hecthor" ]; then
        DATA_YST=`date +%d-%m-%Y -d "-1 day"`
        DATA_NOW=`date +%d-%m-%Y`
        if  ls /joy/backup/hecthor/banco-de-dados | grep -q $DATA_NOW ; then
        echo "OK"
        elif ls /joy/backup/hecthor/banco-de-dados | grep -q $DATA_YST ; then
        echo "OK"
        else
        echo "FAIL"
        fi

   elif [ "$1" = "postgresql" ]; then
        if  ls --full-time /joy/backup/postgresql/imob.tar | grep -q $DATA_NOW ; then
        echo "OK"
        elif ls --full-time /joy/backup/postgresql/imob.tar | grep -q $DATA_YST ; then
        echo "OK"
        else
        echo "FAIL"
        fi
 
   else
   echo "NF" 	
   fi

