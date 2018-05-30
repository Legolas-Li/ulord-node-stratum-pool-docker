#!/usr/bin/env bash


# 替换手续费账号和比率
sed -i "s/\"UVvfixZ1rAXx7ktFCNuRgHrU5yWoDNurEy\": 1.0/\"$REWARD_ADDRESS\": \"$REWARD_PERCENT\"/g" /ulord-node-stratum-pool/pool_configs/ulord.json

echo "set reward address/percent success: $REWARD_ADDRESS: $REWARD_PERCENT" >> /ulord-node-stratum-pool/logs/init.log

sleep 3

# 首次启动时重新创建矿池Ulord地址并写入配置文件。避免使用同一个镜像的人使用同一个地址是一样的风险
if [ -f /ulord-node-stratum-pool/getnewaddress.lock ];then
    echo ''
else
    /UlordChain/src/ulord-cli getnewaddress | xargs -i sed -i 's/"address": ".*"/"address": "{}"/g' /ulord-node-stratum-pool/pool_configs/ulord.json && touch /ulord-node-stratum-pool/getnewaddress.lock
    ps -ef | grep node | awk '{print $2}' | xargs -n 1  kill -9
    echo 'getnewaddress sucess!' >> /ulord-node-stratum-pool/logs/init.log
fi
