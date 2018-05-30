FROM ubuntu:16.04

COPY sources-aliyun.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y git supervisor g++ make pkg-config
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
RUN apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev \
    && apt-get install -y software-properties-common
RUN add-apt-repository ppa:bitcoin/bitcoin \
    && apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev \
    && apt-get install -y libminiupnpc-dev \
    && apt-get install -y libzmq3-dev \
    && apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler \
    && apt-get install -y libqrencode-dev
RUN apt-get install -y autoconf automake libtool libssl-dev
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
RUN apt-get install -y libboost-all-dev
RUN git clone https://github.com/UlordChain/UlordChain.git
RUN cd ./UlordChain \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)"
RUN apt-get -y install redis-server
RUN  apt-get install -y build-essential libsodium-dev npm curl wget \
    && npm install -y n -g \
    && n 4.8.7 \
    && git clone https://github.com/UlordChain/ulord-node-stratum-pool.git ulord-node-stratum-pool

RUN  cd \ulord-node-stratum-pool \
    && npm update

ADD .ulordcore /root/.ulordcore/
ADD etc/supervisor /etc/supervisor/
ADD script /root/
RUN chmod +x /root/*

RUN sed -i 's/appendonly no/appendonly yes/g' /etc/redis/redis.conf

RUN mv /ulord-node-stratum-pool/config_example.json /ulord-node-stratum-pool/config.json

# 创建矿池Ulord地址并设置配置文件
RUN /UlordChain/src/ulordd -daemon \
    && sleep 5 \
    && /UlordChain/src/ulord-cli getnewaddress | xargs -i sed -i 's/"address": ".*"/"address": "{}"/g' /ulord-node-stratum-pool/pool_configs/ulord.json

RUN sed -i 's/appendonly no/appendonly yes/g' /etc/redis/redis.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]