# 开启 mongo
docker run -d --name mongodb -p 27017:27017 mongo
docker run -d --link mongodb:mongodb -p 8081:8081 mongo-express

#开启 parse-server
docker run -d               \
       -e APP_ID=test       \
       -e MASTER_KEY=1VemFayozIlpU4iEmofzSEvf1467078871 \
       -p 1337:1337         \
       --link mongo:mongo   \
       --name parse-server  \
       yongjhih/parse-server

#开启 parse-server-git-clode
#docker run -d -p 2022:22 --volumes-from parse-server --name parse-cloud-code-git yongjhih/parse-server:git

#测试
curl -X POST \
  -H "X-Parse-Application-Id:demo" \
  -H "Content-Type: application/json" \
  -d '{}' \
  http://localhost:1337/parse/functions/hello

  curl -X POST \
  -H "X-Parse-Application-Id:demo" \
  -H "Content-Type: application/json" \
  -d '{"score":1337,"playerName":"Sean Plott","cheatMode":false}' \
  http://192.168.2.101:1337/parse/classes/GameScore

curl -H "X-Parse-Application-Id:demo" \
     -H "X-Parse-Master-Key:demo" \
     -H "Content-Type: application/json" \
     http://192.168.2.101:1337/parse/serverInfo


#启动 parse-Dashboard
### 单个程序
docker run -d \
             -e PARSE_DASHBOARD_APP_ID=test\
             -e PARSE_DASHBOARD_MASTER_KEY=123456\
             -e PARSE_DASHBOARD_APP_NAME=test\
             -e PARSE_DASHBOARD_SERVER_URL=http://54.223.109.139:1337/parse \
             -e PARSE_DASHBOARD_ALLOW_INSECURE_HTTP=1  \
             -e PARSE_DASHBOARD_USER_ID=zhuozhengyun  \
             -e PARSE_DASHBOARD_USER_PASSWORD=zzy12114 \
             -p 4040:4040                      \
             --link parse-server:parse-server               \
             --name parse-dashboard            \
             yongjhih/parse-dashboard


### 多程序
docker run -d \
             -e PARSE_DASHBOARD_ALLOW_INSECURE_HTTP=1  \
             -e PARSE_DASHBOARD_CONFIG='{"apps":[{"serverURL":"http://54.223.109.139:1337/parse","appId":"test","masterKey":"1VemFayozIlpU4iEmofzSEvf1467078871","appName":"test"},{"serverURL":"http://54.223.109.139:8000/parse","appId":"word","masterKey":"kjLzuM6BripEGyPsjZc3zZs71468569398","appName":"word"},{"serverURL":"http://54.223.109.139:8082/parse","appId":"time","masterKey":"x5vwHyeGKkhshiqfU4VwRC8d1471360701","appName":"time"}],"users":[{"user":"zhuozhengyun","pass":"g3HfrqzHpoLp"}]}' \
             -p 4040:4040                      \
             --name parse-dashboard            \
             yongjhih/parse-dashboard


# 启动 mongo dashboard
docker run -d \
    --name mongo-express \
    --link mongo:mongo \
    -p 8081:8081 \
    -e ME_CONFIG_OPTIONS_EDITORTHEME="ambiance" \
    -e ME_CONFIG_BASICAUTH_USERNAME="root" \
    -e ME_CONFIG_BASICAUTH_PASSWORD="root" \
    mongo-express