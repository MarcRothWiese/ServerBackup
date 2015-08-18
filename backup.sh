#!/bin/sh

args=("$@")

logdir="/backup/_logs/"

if [ $# -eq 2 ]; then

        backuphost=${args[0]};
        backupdirectory=${args[1]};
        backupdir="/backup/${args[1]}";

        if [ -d "$backupdir" ]; then
                backupfile=`date +%Y%m%d%H%M%S`
                backupstart=`date +%Y%m%d-%H:%M:%S`
                echo " === BACKUP START $backupstart ===" >> $logdir/backup-$backupdirectory-$backupfile.log
                date=`date "+%Y-%m-%d-%H-%M-%S"`


                rsyncstart=`date +%Y%m%d-%H:%M:%S`
                echo " === START RSYNC $rsyncstart ===" >> $logdir/backup-$backupdirectory-$backupfile.log

                rsync -avzq --progress --delete --log-file=$logdir/backup-$backupdirectory-$backupfile.log --link-dest=$backupdir/current $backuphost $backupdir/incomplete_back-$date

                rsyncstop=`date +%Y%m%d-%H:%M:%S`
                echo " === STOP RSYNC $rsyncstop ===" >> $logdir/backup-$backupdirectory-$backupfile.log

                mv $backupdir/incomplete_back-$date $backupdir/back-$date
                rm -f $backupdir/current
                ln -s $backupdir/back-$date $backupdir/current

                backupstop=`date +%Y%m%d-%H:%M:%S`
                echo " === BACKUP STOP $backupstop ===" >> $logdir/backup-$backupdirectory-$backupfile.log
        fi
fi

