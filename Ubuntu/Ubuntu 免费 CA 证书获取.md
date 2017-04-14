##免费 CA 证书获取

### 具体步骤
 - 打开网站[startssl](https://www.startssl.com/)
 - 注册网站用户
 - 激活后，选择 free 类型
 - 选择 验证，会给发送一次性登录密码。 然后登录。
 - 选择 Validations Wizard
 - 选择 Domain Validation
 - 下一步，填写域名, "docker.humbleadmin.io"
 - 下一步 发送邮件验证域名。 如果不知道邮箱，可以选择 上传文件到服务器root下。
 - 选择验证。 验证完成，选择 Certificates Wizard --》 Web Server SSL/TLS Certificate
 - 第一个文本框（hostname） 写入域名。
 - 生成 CSR 以及 Key 文件 (密码为 humbleadmin.io)
	> 打开终端输入：
```
		$ openssl req -newkey rsa:2048 -keyout humbleadmin.io.key -out humbleadmin.io.csr
		会提示输入一些额外信息，这个可以随便写。以下是示例：

		openssl req -newkey rsa:2048 -keyout humbleadmin.io.key -out humbleadmin.io.csr
		Generating a 2048 bit RSA private key
		...............................................................+++
		.......................................+++
		writing new private key to 'humbleadmin.io.key'
		Enter PEM pass phrase:
		Verifying - Enter PEM pass phrase:
		-----
		You are about to be asked to enter information that will be incorporated
		into your certificate request.
		What you are about to enter is what is called a Distinguished Name or a DN.
		There are quite a few fields but you can leave some blank
		For some fields there will be a default value,
		If you enter '.', the field will be left blank.
		-----
		Country Name (2 letter code) [AU]:ZH
		State or Province Name (full name) [Some-State]:Beijing
		Locality Name (eg, city) []:Beijing
		Organization Name (eg, company) [Internet Widgits Pty Ltd]:ZZY
		Organizational Unit Name (eg, section) []:ZZY
		Common Name (e.g. server FQDN or YOUR name) []:douchunrong
		Email Address []:zhuozhengyun@163.com

		Please enter the following 'extra' attributes
		to be sent with your certificate request
		A challenge password []:humbleadmin.io
		An optional company name []:zzy
```

 - 这时候会生成 key 跟 csr 文件, 复制 csr 文件内容。 粘贴到网站。
	> Please submit your Certificate Signing Request (CSR):
	> 选择第一个，然后粘贴刚刚复制的内容

 - 点击提交。
 - 会看到证书已经颁发,点击 here 去下载证书。
 - 如果证书遗失，可以在 Tool Box 里的 Certificate List 里面随时下载。