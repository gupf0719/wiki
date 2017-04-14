## haproxy 配置 SSL
#### 更新
```
 sudo apt-get update
```
#### 安装支持
```
sudo apt-get install libpcre3 libpcre3-dev  libssl-dev
```
#### 获取 CA 证书,包括 csr key,获取步骤查看 [CA 证书获取](https://git.oschina.net/traynor/MyWiKi/blob/master/Ubuntu/%E5%85%8D%E8%B4%B9%20CA%20%E8%AF%81%E4%B9%A6%E8%8E%B7%E5%8F%96.md?dir=0&filepath=Ubuntu%2F%E5%85%8D%E8%B4%B9+CA+%E8%AF%81%E4%B9%A6%E8%8E%B7%E5%8F%96.md&oid=51ddb07897093577923613906972260617bf2472&sha=8d5b48a77f4ade4fc30eeb8225f3da0c891512c9)
#### 如果 key 有密码 必须去掉。
```
openssl rsa -in humbleadmin.key -out humbleadmin_with_out_pass.key
```
#### 生成 crt
```
mkdir /etc/ssl/humbleadmin
mv humbleadmin_with_out_pass.key /etc/ssl/humbleadmin
mv humadmin.csr /etc/ssl/humbleadmin
openssl x509 -req -days 365 -in /etc/ssl/humbleadmin/humbleadmin.csr -signkey /etc/ssl/humbleadmin/humbleadmin_with_out_pass.key -out /etc/ssl/certs/humbleadmin.crt
```
#### 生成 PEM
```
cat /etc/ssl/humbleadmin/humbleadmin.crt /etc/ssl/humbleadmin/humbleadmin_with_out_pass.key > /etc/ssl/certs/humbleadmin.bundle.pem
```
#### 配置 /etc/haproxy/haproxy.cfg . 下面是配置实例:

```
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
        maxconn 2048
        tune.ssl.default-dh-param 2048
        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL).
        ssl-default-bind-ciphers kEECDH+aRSA+AES:kRSA+AES:+AES256:RC4-SHA:!kEDH:!LOW:!EXP:!MD5:!aNULL:!eNULL
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option http-server-close
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend http_80_in
        bind *:80
        bind 0.0.0.0:443 ssl crt /etc/ssl/certs/humbleadmin.pem
        reqadd X-Forwarded-Proto:\ https
        rspadd Strict-Transport-Security:\ max-age=31536000
        option forwardfor
        option http-server-close
        default_backend www.develop.humbleadmin.com

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