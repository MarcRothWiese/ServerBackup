# Server Backup Script
Backup script for backing up Linux servers.

For running script use this:
```
/path/to/backup.sh username@server:/path/to/backup backupfoldername
```

First Backup
```
rsync -az username@server:/path/to/backup /backup/backupfoldername/firstbackup
ln -s /backup/backupfoldername/firstbackup /backup/backupfoldername/current
```
