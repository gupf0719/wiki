Ubuntu docker 安装步骤

1. $ sudo apt-get update
2. $ sudo apt-get -y install linux-image-generic-lts-trusty
3. $ sudo apt-get -y install docker.io
4. $ sudo usermod -aG docker ubuntu
5. $ sudo reboot


sudo apt-get -y install docker.io &&  sudo usermod -aG docker ubuntu  && sudo reboot

＃国内 ubuntu 镜像
docker run daocloud.io/ubuntu:15.14 grep -v '^#' /etc/apt/sources.list

docker tag imageID name