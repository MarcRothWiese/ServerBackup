#!/bin/bash

args=("$@")

logdir="/backup/clients/_logs"
uses3=1;

if [ $# -eq 3 ]; then

        backuptype=${args[0]};
        backuphost=${args[1]};
        backupdirectory=${args[2]};
        backupdir="/backup/clients/${args[2]}";
        backupfile=`date +%Y%m%d%H%M%S`
        backupstart=`date +%Y%m%d-%H:%M:%S`
        backuplog=$logdir/backup-$backupdirectory-$backupfile.log
        echo $backuplog;
        date=`date "+%Y-%m-%d-%H-%M-%S"`

        mkdir -p $backupdir

        if [ -d "$backupdir" ]; then
                echo " === BACKUP START $backupstart ===" >> $backuplog

                rsyncstart=`date +%Y%m%d-%H:%M:%S`
                echo " === START RSYNC $rsyncstart ===" >> $backuplog

                rsync -azq --delete --log-file=$logdir/backup-$backupdirectory-$backupfile.log $backuphost $backupdir/current
                wait

                rsyncstop=`date +%Y%m%d-%H:%M:%S`
                echo " === STOP RSYNC $rsyncstop ===" >> $backuplog


                #
                # Making DIFF package..
                #

                if [ "$backuptype" == "diff" ]; then
                    diffstart=`date +%Y%m%d-%H:%M:%S`
                    echo " === START DIFF PACKAGE $diffstart ===" >> $backuplog

                    mkdir -p /backup/archive/backups/${args[2]}/diffs/
                    rsync -axq --compare-dest=$backupdir/latest/ $backupdir/current/ $backupdir/diff-$date
                    wait

                    tar --verbose -cf "${backupdir}/diff-${date}.tar" "${backupdir}/diff-${date}" >> $backuplog
                    /bin/cp -f "${backupdir}/diff-${date}.tar" /backup/archive/backups/${args[2]}/diffs/
                    rm -rf "${backupdir}/diff-${date}"

                    #
                    # S3 - Upload
                    #
                    if [ $uses3 -eq 1 ]; then
                        s3cmd put "${backupdir}/complete-${date}.tar" s3://wieseservices/backup/${args[2]}/diff/
                        path="s3://wieseservices/backup/${args[2]}/diff/diff-${date}.tar"
                        count=`s3cmd ls $path | wc -l`
                        if [[ $count -eq 0 ]]; then
                                s3cmd --multipart-chunk-size-mb=5 put "${backupdir}/diff-${date}.tar" s3://wieseservices/backup/${args[2]}/diff/
                                echo "UPLOAD - Multipart success" >> $backuplog
                        else
                                echo "UPLOAD - First success" >> $backuplog
                        fi
                    fi

                    rm -f "${backupdir}/diff-${date}.tar"

                    diffstop=`date +%Y%m%d-%H:%M:%S`
                    echo " === STOP DIFF PACKAGE $diffstop ===" >> $backuplog
                fi



                #
                # Making Complete package..
                #
                if [ "$backuptype" == "complete" ]; then
                    completestart=`date +%Y%m%d-%H:%M:%S`
                    echo " === START COMPLETE PACKAGE $completestart ===" >> $backuplog

                    mkdir -p /backup/archive/backups/${args[2]}/complete/month/
                    tar --verbose -cf "${backupdir}/complete-${date}.tar" "${backupdir}/current" >> $backuplog
                    /bin/cp -f "${backupdir}/complete-${date}.tar" /backup/archive/backups/${args[2]}/complete/month/

                    #
                    # S3 - Upload
                    #
                    if [ $uses3 -eq 1 ]; then
                        s3cmd put "${backupdir}/complete-${date}.tar" s3://wieseservices/backup/${args[2]}/complete/
                        path="s3://wieseservices/backup/${args[2]}/complete/complete-${date}.tar"
                        count=`s3cmd ls $path | wc -l`
                        if [[ $count -eq 0 ]]; then
                                s3cmd --multipart-chunk-size-mb=5 put "${backupdir}/complete-${date}.tar" s3://wieseservices/backup/${args[2]}/complete/
                                echo "UPLOAD - Multipart success" >> $backuplog
                        else
                                echo "UPLOAD - First success" >> $backuplog
                        fi
                    fi

                    rm -f "${backupdir}/complete-${date}.tar"

                    completestop=`date +%Y%m%d-%H:%M:%S`
                    echo " === STOP COMPLETE PACKAGE $completestop ===" >> $backuplog
                fi

                rsync -azq --delete --log-file=$logdir/backup-$backupdirectory-$backupfile.log $backupdir/current/ $backupdir/latest
                wait


                backupstop=`date +%Y%m%d-%H:%M:%S`
                echo " === BACKUP STOP $backupstop ===" >> $backuplog
        fi
fi

