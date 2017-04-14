## 说明
github hooks 自动获取代码工具

## Install
```
$ mkdir githubHooks

$ sudo apt-get update

$ sudo  apt-get install -y nodejs

$ sudo apt-get install -y npm

$ sudo ln -s /usr/bin/nodejs /usr/bin/nodes

$ npm install exec 

```
## 拷贝

```
$ vim server.js
将 server.js 内内容拷贝到文件内。
```

## 运行

```
$ nohup node server.js > ~/gihubHooks/hooks.log &
```
## Server.js 使用说明
### 自定义变量说明
```
PORT : 运行端口默认 3000
BASE_PATH ：项目根目录
```
### 命令说明
```
    var commands = [
      'cd ' + BASE_PATH + object_url, //进入项目目录
      'git pull origin master', // 获取最新版本
      'sudo rm -rf /var/www/html/*', // 删除以前版本
      'suco cp ~/GTD/* /var/www/html/', // 拷贝最新版本
      'sudo /etc/init.d/apache2 restart' // 重启服务器
    ].join(' && ')
```
所有的项目操作命令，写入 commands 数组，用逗号分隔。

### 接口说明
```
默认接口地址：http://xxxxx:3000
可以看到 server.js 内的代码  
- __ /deploy\/.*/i __ 这里的 ** deoloy ** 是路径，可自定义.（http://xxxxx:3000/deploy/）
- __ var object_url = request.url.split("/")[2] __ 这里是截取路径，截取 deoloy 后的路径名称，当作项目名。
```
所以，在 github 上的路径写为： http://xxxxx:3000/deploy/项目名称

