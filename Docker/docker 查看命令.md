docker 查看IP
$ docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID

docker 查看端口
docker inspect --format='{{.NetworkSettings.Ports.3000/tcp.HostPort}}' $CONTAINER_ID
docker inspect --format='{{.NetworkSettings.Ports.\"3000/tcp\".HostPort}}' c1a7b338372f