#!/bin/sh
#Copyright(c) 2010-2011 Dz (douchunrong@gmail.com)　
#Backup the Docker files
#Version 1.0.0

echo "step 1 : start tar images ......"
if [[ $# <= 0  ]]; then
	echo "参数为空"
	return
fi

docker_contaners = $1
back_path = $2

docker commit -p $docker_contaners new_"$docker_contaners"
docker save -o "$back_path"/"$docker_contaners".tar $docker_contaners