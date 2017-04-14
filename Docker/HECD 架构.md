# HECD 架构

### 简介

#### 环境
- ubuntu >= 14.04
- H - HAProxy 
- E - ETCD ~> 0.12.0
- C - confd ~> v2.3.0
- D - Docker ~> v.1.6.2


### 下载 

`ETCD`

```javascript
$ curl -L  https://github.com/coreos/etcd/releases/download/v2.3.0-alpha.1/etcd-v2.3.0-alpha.1-linux-amd64.tar.gz -o etcd-v2.3.0-alpha.1-linux-amd64.tar.gz
```
`confd`
```javascript
$  wget https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64
```

### 安装

`Docker`

```javascript
$ apt-get install -y docker.io
```

`HAProxy`

```javascript
$ sudo apt-get install -y haproxy
```

`ETCD`

```
$ tar xzvf etcd-v2.3.0-alpha.1-linux-amd64.tar.gz
$ cd etcd-v2.3.0-alpha.1-linux-amd64
$ sudo cp etcd* /usr/bin/
$ etcd -version
```

`confd`

```javascript
$ sudo mv confd* /usr/bin/confd  
$ sudo chmod +x /usr/bin/confd  
$ confd -version
```

### 配置
- `Haproxy`
    - 修改配置

    ```javascript
    /etc/default/haproxy
    ```

- `ETCD`
    - 不需要配置，在启动时配置携带参数。详情查看 _启动_
- `Confd` *&&* `HAProxy`
    - __配置资源文件__

	```
	$ sudo mkdir -p /etc/confd/{conf.d,templates}
	```
	```
	$ sudo vim /etc/confd/conf.d/haproxy.toml
	```
	写入以下内容：
	```
	[template] 	 
	src = "haproxy.cfg.tmpl"  
	dest = "/etc/haproxy/haproxy.cfg"  
	keys = [  
	  "/app/servers",  
	]  
	reload_cmd = "/etc/init.d/haproxy reload" 
	```
__说明__: 其中 __src__ 为指定模板文件名称（默认到路径/etc/confd/templates中查找）；_dest_ 指定生成的 Haproxy 配置文件路径；_keys_ 指定关联 Etcd 中 key 的 URI 列表；_reload_cmd_ 指定服务重载的命令，本例中配置成 haproxy 的 reload 命令
	
	- __配置模板文件__

	```javascript
	sudo vim /etc/confd/templates/haproxy.cfg.tmpl
	```
	写入以下内容：

```javascript

global
        log 127.0.0.1 local3
        maxconn 5000
        uid 99
        gid 99
        daemon

defaults
        log 127.0.0.1 local3
        mode http
        option dontlognull
        retries 3
        option redispatch
        maxconn 2000
        contimeout  5000
        clitimeout  50000
        srvtimeout  50000

frontend http_80_in
        bind *:80
        mode http
        option httpclose
        option forwardfor

        {{range gets "/app/servers/*"}}
        acl header_{{base .Key}} hdr(APPID) -i eq {{base .Key}}
        {{end}}

        {{range gets "/app/servers/*"}}
        use_backend {{base .Key}} if header_{{base .Key}}
        {{end}}

        default_backend www.develop.humbleadmin.com

        {{range gets "/app/servers/*"}}
        backend {{base .Key}}
        server {{base .Key}} {{.Value}}  check inter 5000 fall 1 rise 2
        {{end}}

        backend www.develop.humbleadmin.com
        mode http
        option  forwardfor
        balance roundrobin    #负载均衡的方式,轮询方式

        server developer 54.222.199.254:80  check inter 2000 rise 3 fall 3 weight 3

listen admin-status
        bind 0.0.0.0:8080
        mode http
        stats refresh 30s
        stats enable
        stats uri /admin-status
        stats auth admin:123456
        stats admin if TRUE
```

__说明__: `Confd` 模板引擎采用了 `Go` 语言的文本模板，更多见[golang template](//golang.org/pkg/text/template)，具备简单的逻辑语法，包括循环体、处理函数等，本示例的模板文件如下，通过 `range` 循环输出 _Key_ 及 _Value_ 信息。

### 启动

`ETCD`

```
$ nohup etcd  --data-dir '/data'  --listen-peer-urls 'http://172.31.19.162:2380,http://172.31.19.162:7001' --listen-client-urls 'http://172.31.19.162:2379,http://172.31.19.162:4001' --initial-advertise-peer-urls 'http://172.31.19.162:2380,http://172.31.19.162:7001' --initial-cluster 'default=http://172.31.19.162:2380,default=http://172.31.19.162:7001'  --advertise-client-urls 'http://172.31.19.162:2379,http://172.31.19.162:4001' &   
```
__说明__: 由于 ETCD 具备多机支持，参数 `-peer-addr` 指定与其它节点通讯的地址；参数 `-addr` 指定服务监听地址；参数 `-data-dir` 为指定数据存储目录。 另外，此处的 ip 在 EC2 中为 ec2 的内网 ip.

由于 ETCD 是通过 REST-API 方式进行交互，常见操作如下:

设置(set) key 操作

```
$ curl -XPUT http://localhost:4001/v2/keys/app/servers/acdea7a876c8 -d value="54.222.199.254:32769"  
```
> {"action":"set","node":{"key":"/mykey","value":"this is awesome","modifiedIndex":28,"createdIndex":28}}

获取(get) key 信息

```
$ curl -L http://localhost:4001/v2/keys/mykey
```
> {"action":"get","node":{"key":"/mykey","value":"this is awesome","modifiedIndex":28,"createdIndex":28}}

删除 key 信息

```
curl -L http://localhost:4001/v2/keys/mykey -XDELETE
curl -L http://54.200.188.47:4001/v2/keys/app/servers/kTutZ4chFqQlKCdrwQYG3Qxb1461922239 -XDELETE
```
> {"action":"delete","node":{"key":"/mykey","modifiedIndex":29,"createdIndex":28},"prevNode":{"key":"/mykey","value":"this is awesome","modifiedIndex":28,"createdIndex":28}}

`Confd`

```
$ sudo vim /var/log/confd.log
$ sudo chmod +wr /var/log/confd.log 
$ nohup confd  -interval 10 -node 'http://54.222.188.173:4001' -confdir /etc/confd > /var/log/confd.log &
```

说明: 参数 `interval` 为指定探测 _etcd_ 的频率，单位为秒，参数 `-node` 为指定 _etcd_ 监听服务主地址，以便获取容器信息


### 参考
- [构建一个高可用及自动发现的Docker基础架构-HECD](http://blog.liuts.com/post/242/)