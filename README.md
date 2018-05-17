# Server Backup Script
Backup script for backing up Linux servers.

For running script use this:
```
/path/to/backup.sh command username@server:/path/to/backup backupfoldername
```

First Backup
```
rsync -az username@server:/path/to/backup /backup/backupfoldername/firstbackup
ln -s /backup/backupfoldername/firstbackup /backup/backupfoldername/current
```

For differential backups - Then only changes from previous backup is saved.
```
/path/to/backup.sh diff username@server:/path/to/backup backupfoldername
```

For complete backups - All is backupped
```
/path/to/backup.sh complete username@server:/path/to/backup backupfoldername
```
