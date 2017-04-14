## ubuntu 定时清理内存
```
$ cd ~ 
```
```
$ mkdir cacheclear
```
```
$ vim /home/ubuntu/cacheclear/cacheclear.sh
```

写入：
```
#!/bin/sh  
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"  
echo "clear cache at "`date`" executed" 
```
```
$ sudo chmod 777 /home/ubuntu/cacheclear/cacheclear.sh
```
```
$ sudo crontab -e
```
末尾写入：
```
*/30 * * * * /home/ubuntu/cacheclear/cacheclear.sh >> /home/ubuntu/cacheclear/cacheclear.log
```
```
$ sudo vim /etc/rsyslog.d/50-default.conf  
```
去除 `#cron` 前的 `#`

重启服务
```
$ sudo service rsyslog restart
```
```
$ sudo service cron restart
```
