# 免 git pull／push 密码

### 配置
```
$ git config --global user.name "aaa"
$ git config --global user.email "aaa@mail.com"
```

### 添加
```
$ vim  ~/.git-credentials
```

__ 添加内容 __

```
https://UserEmail:password@github.com
```

__ 终端输入内容 __

```
$ git config --global credentials.helper store
```


###  再次输入密码
 - 进入到项目下再次 `git pull`
 - 输入用户邮箱  密码
 - 等下次再获取时就免密码了