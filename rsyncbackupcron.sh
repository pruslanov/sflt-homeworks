date
echo "Start backup "
rsync -a --progress --checksum /home/vagrant/ /tmp/backup
date
echo "Backup finished"
