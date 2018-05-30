FROM ubuntu:16.04
LABEL maintainer="daoying007 <daoying007@gmail.com>"
LABEL maintainer_ulord_address="UjveZHp4HeE6g4H1SouBjGZuGE2GPjxREW"
LABEL github="https://github.com/daoying007/ulord-node-stratum-pool-docker"

COPY sources-aliyun.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y git supervisor g++ make pkg-config build-essential libtool autotools-dev automake libssl-dev libevent-dev bsdmainutils autoconf libboost-all-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev software-properties-common libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libsodium-dev npm curl wget

RUN add-apt-repository ppa:bitcoin/bitcoin \
    && apt-get update

RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

#  安装redis
RUN apt-get -y install redis-server

# 安装UlordChain
RUN git clone https://github.com/UlordChain/UlordChain.git
RUN cd ./UlordChain \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)"

# 安装ulord-node-stratum-pool
RUN npm install -y n -g \
    && n 4.8.7 \
    && git clone https://github.com/UlordChain/ulord-node-stratum-pool.git ulord-node-stratum-pool \
    && cd \ulord-node-stratum-pool \
    && npm update

# 设置配置文件
ADD .ulordcore /root/.ulordcore/
ADD etc/supervisor /etc/supervisor/
ADD script /root/
RUN chmod +x /root/*

# 初始化ulord-node-stratum-pool配置文件
RUN mv /ulord-node-stratum-pool/config_example.json /ulord-node-stratum-pool/config.json

# 创建矿池Ulord地址并写入配置文件
RUN /UlordChain/src/ulordd -daemon \
    && sleep 5 \
    && /UlordChain/src/ulord-cli getnewaddress | xargs -i sed -i 's/"address": ".*"/"address": "{}"/g' /ulord-node-stratum-pool/pool_configs/ulord.json

# 持久化redis
RUN sed -i 's/appendonly no/appendonly yes/g' /etc/redis/redis.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]