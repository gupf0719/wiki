Docker 使用主机 mysql 配置
1. 首先确保主机安装有 Mysql
	查看 ip 
	ip addr show docker0
	一般默认为 172.17.0.1
这个地址就是可以跟 Host 互通消息的接口

2. 修改用户权限
进入MySQL
方法一： 使用 root 用户

~mysql>  CREATE USER 'root'@'%' IDENTIFIED BY 'rntd12114';
~mysql>  GRANT ALL PRIVILEGES ON *.* TO 'openid_server'@'%' WITH GRANT OPTION;

方法二： 新建用户
~mysql>  CREATE USER 'openid_server'@'%' IDENTIFIED BY 'rntd12114';
~mysql>  GRANT ALL PRIVILEGES ON *.* TO 'openid_server'@'%' WITH GRANT OPTION;
~mysql>  CREATE USER 'openid_server'@'localhost' IDENTIFIED BY 'rntd12114';
~mysql>  GRANT ALL PRIVILEGES ON *.* TO 'openid_server'@'localhost' WITH GRANT OPTION;

这样项目中就可以使用配置好的用户以及默认 ip 就可以了。