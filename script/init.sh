#!/usr/bin/env bash


# 替换手续费账号和比率
sed -i "s/\"UVvfixZ1rAXx7ktFCNuRgHrU5yWoDNurEy\": 1.0/\"$REWARD_ADDRESS\": \"$REWARD_PERCENT\"/g" /ulord-node-stratum-pool/pool_configs/ulord.json

# 重新生成矿池收账地址
# sleep 2
# /UlordChain/src/ulord-cli getnewaddress | xargs -i sed -i 's/"address": ".*"/"address": "{}"/g' /ulord-node-stratum-pool/pool_configs/ulord.json
# cd /ulord-node-stratum-pool && npm start

sleep 3