#ulord-node-stratum-pool-docker


作者：daoying007 <daoying007@gmail.com>

作者Ulord地址：`UjveZHp4HeE6g4H1SouBjGZuGE2GPjxREW` 欢迎打赏

github地址：https://github.com/daoying007/ulord-node-stratum-pool-docker

### 一、编译镜像

进入Dockerfile文件所在目录，编译镜像：

```
docker build -t ulord-pool:latest .
```

### 二、运行容器

方式一，直接运行容器：

```
docker run -v ~/ulord-pool-redis-data:/var/lib/redis -p 80:8080 -p 7200:7200 -e REWARD_ADDRESS=UjveZHp4HeE6g4H1SouBjGZuGE2GPjxREW -e REWARD_PERCENT=2.0 --name ulordpool_ulord-pool_1 ulord-pool:latest
```


方式二，使用 docker-compose 运行，
创建 docker-composer.yml 文件，填入如下代码：

```
ulord-pool:
    image: ulord-pool:latest
    restart: always
    environment:
        - REWARD_ADDRESS=UjveZHp4HeE6g4H1SouBjGZuGE2GPjxREW
        - REWARD_PERCENT=2.0
    ports:
        - 80:8080
        - 7200:7200
    volumes:
      - ~/ulord-pool-redis-data:/var/lib/redis
```

进入docker-composer.yml文件所在目录，运行命令：

```
docker-compose up
```

注意：记得修改上面的地址 `UjveZHp4HeE6g4H1SouBjGZuGE2GPjxREW` 为你自己的Ulord地址，否则就是给作者打赏了

### 三、查看日志

进入容器：

```
docker exec -it ulordpool_ulord-pool_1 bash
```

查看运行日志：

```
tail -f /var/log/ulord-pool.log 
```

### 四、重新生成矿池Ulord地址 & 自动配置 & 自动重启服务
```
/UlordChain/src/ulord-cli getnewaddress | xargs -i sed -i 's/"address": ".*"/"address": "{}"/g' /ulord-node-stratum-pool/pool_configs/ulord.json && ps -ef | grep node | awk '{print $2}' | xargs -n 1  kill -9
```

### 五、异常解决

运行时偶然会遇到如下问题：

https://github.com/UlordChain/ulord-node-stratum-pool/issues/44

```
2018-05-30 03:08:57 [Pool]      [ulord] (Thread 1) Downloaded 0.00% of blockchain from 1 peers
2018-05-30 03:08:57 [Pool]      [ulord] (Thread 1) Downloaded 0.00% of blockchain from 2 peers
2018-05-30 03:09:02 [Pool]      [ulord] (Thread 4) getblocktemplate call failed for daemon instance 0 with error {"code":-9,"message":"Ulord Core is not connected!"}
2018-05-30 03:09:02 [Pool]      [ulord] (Thread 4) Error with getblocktemplate on creating first job, server cannot start
```

如日志里出现如上错误，请使用以下命令解决，系统会自动重启矿池服务

```
ps -ef | grep node | awk '{print $2}' | xargs -n 1  kill -9
```
然后再 `tail -f /var/log/ulord-pool.log` 通过日志看运行是否正常