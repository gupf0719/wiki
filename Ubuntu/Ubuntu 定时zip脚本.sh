#!/bin/bash
cd /data
TODAY=$(date +%Y%m%d)
THREEDAY=$(date -d "-3 days" +%Y%m%d)
EXCENAME=".zip"
#print today date
echo "today is :" $TODAY
echo "3 days ago is :" $THREEDAY
sudo zip -r ~/crontab/backMan/MongoData/$TODAY$EXCENAME ./*
echo "Zip Ok"
# into zip dir
cd ~/crontab/backMan/MongoData/
# del 3 dayes ago files
sudo rm -rf $THREEDAY$EXCENAME
echo "Delete Zip Ok"

