## EC2 shipyard 部署

### 部署

#### 主机
首次部署，运行：
```
$ curl -sSL https://shipyard-project.com/deploy | bash -s
```

##### 修改 web 端口
如果遇到端口冲突：

```
$ curl -sSL https://shipyard-project.com/deploy | PORT=80 bash -s 
```
_注意_: 这里的`PORT`仅仅是 shipyard 的监控页面端口，默认端口 8080。

#### 从机 

添加节点
```
curl -sSL https://shipyard-project.com/deploy | ACTION=node DISCOVERY=etcd://$host-ip:4001  bash -s
```
_注意:_这里 `$host-ip` 是指主机（即主节点）的ip。 此命令是在`从机(子节点)`上运行。

例子：
```
curl -sSL https://shipyard-project.com/deploy | ACTION=node DISCOVERY=etcd://172.31.17.146:4001  bash -s
```

### EC2 安全策略修改
选择 `安全组`, 进入后选中自己主机的具体安全组，并点击 `操作` -> `编辑入站规则`。
添加 `自定义 TCP 规则`，端口范围 `2375`，来源 `任何位置`。
添加 `所有 ICMP`，默认端口范围，来源 `任何位置`.

添加完毕，保存。
此刻集群添加完成。
