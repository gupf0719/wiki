docker 镜像打包 备份容器

1. 创建快照
	$  docker commit -p 容器ID 快照名称

2. 备份容器
	方式一：打包成 tar并保存到本地
	$ docker save -o ~/container-backup.tar container-backup

	PS:
	container-backup.tar： 打包文件名
	container-backup: images 名称

	方式二： Hub docker 上传
		1. $ docker tag a25ddfec4d2a arunpyasi/container-backup:test

	PS: 打 tag
		docker tag 容器ID 用户名/仓库名: Tag 名
	

		2. $ docker push arunpyasi/container-backup

	PS: 上传
		docker push 用户名/仓库名

	

docker 数据恢复

方式一：
	解压压缩包

		$ docker load -i ~/压缩包名称.tar

方式二：
	如果在 Hub Docker 备份过，那么：
		$ docker pull 用户名/仓库名:tag



Docker 数据迁移

迁移容器同时涉及到了上面两个操作，备份和恢复。我们可以将任何一个Docker容器从一台机器迁移到另一台机器。在迁移过程中，首先我们将把容器备份为Docker镜像快照。然后，该Docker镜像或者是被推送到了Docker注册中心，或者被作为tar包文件保存到了本地。如果我们将镜像推送到了Docker注册中心，我们简单地从任何我们想要的机器上使用 docker run 命令来恢复并运行该容器。但是，如果我们将镜像打包成tar包备份到了本地，我们只需要拷贝或移动该镜像到我们想要的机器上，加载该镜像并运行需要的容器即可。