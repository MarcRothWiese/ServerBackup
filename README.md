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

For differential backups - Only the changes different from previous backup is saved.
```
/path/to/backup.sh diff username@server:/path/to/backup backupfoldername
```

For complete backups - There is made a backup of all data
```
/path/to/backup.sh complete username@server:/path/to/backup backupfoldername
```
