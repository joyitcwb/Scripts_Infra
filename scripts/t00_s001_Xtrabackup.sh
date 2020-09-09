#!/bin/bash
# This is my production backup script.
# https://sqlgossip.com

set -e
set -u

usage() {
        echo "usage: $(basename $0) [option]"
        echo "option=full: Perform Full Backup"
        echo "option=incremental: Perform Incremental Backup"
        echo "option=restore: Start to Restore! Be Careful!! "
        echo "option=help: show this help"
}

full_backup() {

        if [ ! -d $BACKUP_DIR ]
        then
            mkdir $BACKUP_DIR
        fi

        rm -rf $BACKUP_DIR/*
        echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Cleanup the backup folder is done! Starting backup" >> $BACKUP_DIR/xtrabackup.log

        xtrabackup --backup -u$USER -p$SECRET --history --compress --compress-threads=8 --target-dir=$BACKUP_DIR/FULL
        echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Backup Done!" >> $BACKUP_DIR/xtrabackup.log
}

incremental_backup()
{
        if [ ! -d $BACKUP_DIR/FULL ]
        then
                echo "ERROR: Unable to find the FULL Backup. aborting....."
                exit -1
        fi

        if [ ! -f $BACKUP_DIR/last_incremental_number ]; then
            NUMBER=1
        else
            NUMBER=$(($(cat $BACKUP_DIR/last_incremental_number) + 1))
        fi

        echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Starting Incremental backup $NUMBER" >> $BACKUP_DIR/xtrabackup.log
        if [ $NUMBER -eq 1 ]
        then
                xtrabackup --backup  --history --incremental --target-dir=$BACKUP_DIR/inc$NUMBER --incremental-basedir=$BACKUP_DIR/FULL
        else
                xtrabackup --backup  --history --incremental --target-dir=$BACKUP_DIR/inc$NUMBER --incremental-basedir=$BACKUP_DIR/inc$(($NUMBER - 1))
        fi

        echo $NUMBER > $BACKUP_DIR/last_incremental_number
        echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Incremental Backup:$NUMBER done!"  >> $BACKUP_DIR/xtrabackup.log
}

restore()
{
            echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing the FULL backup" >> $BACKUP_DIR/xtrabackup-restore.log
            xtrabackup --decompress --remove-original --parallel=4 --target-dir=$BACKUP_DIR/FULL
            echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing Done !!!" >> $BACKUP_DIR/xtrabackup-restore.log

            echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Prepareing FULL Backup ..." >> $BACKUP_DIR/xtrabackup-restore.log
            xtrabackup --prepare  --apply-log-only --target-dir=$BACKUP_DIR/FULL
            echo `date '+%Y-%m-%d %H:%M:%S:%s'`": FULL Backup Preparation Done!!!" >> $BACKUP_DIR/xtrabackup-restore.log


            P=1
            while [ -d $BACKUP_DIR/inc$P ] && [ -d $BACKUP_DIR/inc$(($P+1)) ]
            do
                  echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing incremental:$P" >> $BACKUP_DIR/xtrabackup-restore.log
                  xtrabackup --decompress --remove-original --parallel=4 --target-dir=$BACKUP_DIR/inc$P
                  echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing incremental:$P Done !!!" >> $BACKUP_DIR/xtrabackup-restore.log

                  echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Prepareing incremental:$P"  >> $BACKUP_DIR/xtrabackup-restore.log
                  xtrabackup --prepare --apply-log-only --target-dir=$BACKUP_DIR/FULL --incremental-dir=$BACKUP_DIR/inc$P
                  echo `date '+%Y-%m-%d %H:%M:%S:%s'`": incremental:$P Preparation Done!!!" >> $BACKUP_DIR/xtrabackup-restore.log
                  P=$(($P+1))
            done

            if [ -d $BACKUP_DIR/inc$P ]
            then
                echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing the last incremental:$P" >> $BACKUP_DIR/xtrabackup-restore.log
                xtrabackup --decompress --remove-original --parallel=4 --target-dir=$BACKUP_DIR/inc$P
                echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Decompressing the last incremental:$P Done !!!" >> $BACKUP_DIR/xtrabackup-restore.log

                echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Prepareing the last incremental:$P"  >> $BACKUP_DIR/xtrabackup-restore.log
                xtrabackup --prepare --target-dir=$BACKUP_DIR/FULL --incremental-dir=$BACKUP_DIR/inc$P
                echo `date '+%Y-%m-%d %H:%M:%S:%s'`": Last incremental:$P Preparation Done!!!" >> $BACKUP_DIR/xtrabackup-restore.log
            fi

}

## Parameters

BACKUP_DIR=/joy/backup/mysql
DATA_DIR=/var/lib/mysql

if [ $# -eq 0 ]
then
usage
exit 1
fi

    case $1 in
        "full")
            full_backup
            ;;
        "incremental")
        incremental_backup
            ;;
        "restore")
        restore
            ;;
        "help")
            usage
            break
            ;;
        *) echo "invalid option";;
    esac