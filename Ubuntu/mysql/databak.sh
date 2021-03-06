#!/bin/sh

DUMP=/usr/bin/mysqldump #mysqldump备份程序执行路径

OUT_DIR=/usr/local/data_bak #备份文件存放路径

FILE_DIR=/home/shengshihui/www/ror/dotshouji_server/public #需要备份的文件路径 

LINUX_USER=sshsql #系统用户名

DB_NAME=dotshouji_server_production #要备份的数据库名字

DB_USER=root #数据库账号 注意：非root用户要用备份参数 --skip-lock-tables，否则可能会报错

DB_PASS= #数据库密码

DAYS=7 #DAYS=7代表删除7天前的备份，即只保留最近7天的备份

cd $OUT_DIR #进入备份存放目录

DATE=`date +%Y_%m_%d` #获取当前系统时间

OUT_SQL="$DATE.sql" #备份数据库的文件名
OUT_RES="$DATE_publlic" #备份数据的文件名

TAR_SQL="mysqldata_bak_$DATE.tar.gz" #最终保存的数据库备份文件名
TAR_RES="resdata_bak_$DATE.tar.gz" #最终保存的文件名

$DUMP -u$DB_USER -p$DB_PASS $DB_NAME --default-character-set=utf8 --opt -Q -R --skip-lock-tables> $OUT_SQL #备份
cp -r $FILE_DIR> $OUT_RES

tar -czf $TAR_SQL ./$OUT_SQL #压缩为.tar.gz格式
tar -czf $TAR_RES ./$OUT_RES #压缩为.tar.gz格式

rm $OUT_SQL #删除.sql格式的备份文件

chown $LINUX_USER:$LINUX_USER $OUT_DIR/$TAR_SQL #更改备份数据库文件的所有者

find $OUT_DIR -name "mysqldata_bak*" -type f -mtime +$DAYS -exec rm {} \; #删除7天前的备份文件(注意：{} \;中间有空格)
find $OUT_DIR -name "resdata_bak*" -type f -mtime +$DAYS -exec rm {} \;