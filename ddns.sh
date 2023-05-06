#!/bin/bash

# 获取接口名称，默认获取 wg* 格式的接口名，其他格式可自行修改命令
interfaces=$(uci show network | grep "=interface" | grep "wg" | cut -d '.' -f 2 | cut -d '=' -f 1)

for iface in ${interfaces[@]}
do
  # 获取peer的域名，我自己是单peer，所以这里仅获取第一个peer的域名，如果有多个peer，可以再嵌套一个循环
  peer=$(uci get network.@wireguard_$iface[0].endpoint_host 2>/devnull)

  # 对面无公网ip，无能为力，跳过
  if [ -z "$peer" ]; then
          continue
  fi

  last_handshake=$(wg show $iface latest-handshakes | awk '{print $2}')

  time_diff=$(expr $(date +%s) - $last_handshake)

  if [ $time_diff -lt 150 ]
  then
          continue
  fi

  ip=$(nslookup $peer | awk '/^Address: / { print $2 }')

  if [ -z "$ip" ]
  then
          logger -t wireguard-ddns "$(date "+%Y-%m-%d %H:%M:%S") - Resolve $peer on $iface failed"
          continue
  fi

  # 如果你有多个peer这里也需要一些处理
  current_ip=$(wg show $iface endpoints | awk '{print $2}' | awk -F: '{print $1}')

  if [ "$current_ip" != "$ip" ]
  then
    logger -t wireguard-ddns "$(date "+%Y-%m-%d %H:%M:%S") - $current_ip => $ip on interface $iface"
    logger -t wireguard-ddns "$(date "+%Y-%m-%d %H:%M:%S") - Restarting WireGuard interface $iface"
    ifup $iface
    logger -t wireguard-ddns "$(date "+%Y-%m-%d %H:%M:%S") - WireGuard interface $iface up"
  fi
done