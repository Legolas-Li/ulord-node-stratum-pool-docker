#!/usr/bin/env bash


# 替换手续费账号和比率
sed -i "s/\"UVvfixZ1rAXx7ktFCNuRgHrU5yWoDNurEy\": 1.0/\"$REWARD_ADDRESS\": \"$REWARD_PERCENT\"/g" /ulord-node-stratum-pool/pool_configs/ulord.json

sleep 3