#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child" 2>/dev/null
}

writeMapping() {
    frontendPort=${1%%:*}
    backend=${1#*:}

    echo "frontend in${frontendPort}" >> haproxy.cfg
    echo "    bind *:${frontendPort}" >> haproxy.cfg
    echo "    default_backend out${frontendPort}" >> haproxy.cfg
    echo >> haproxy.cfg

    if [ ! -z "$WHITELIST_SRCS" ]; then
        echo "    acl whitelist_src src -f whitelist.txt" >> haproxy.cfg
        echo "    tcp-request connection silent-drop if !whitelist_src" >> haproxy.cfg
        echo >> haproxy.cfg
    fi

    if [ ! -z "$BLACKLIST_SRCS" ]; then
        echo "    acl blacklist_src src -f blacklist.txt" >> haproxy.cfg
        echo "    tcp-request connection silent-drop if blacklist_src" >> haproxy.cfg
    fi

    echo "backend out${frontendPort}" >> haproxy.cfg
    echo "    server s1 ${backend} check inter 5s fall 5 rise 5 send-proxy-v2" >> haproxy.cfg
    echo >> haproxy.cfg
}

trap _term SIGTERM

MAX_CONN=${MAX_CONN:-10000}
STATS_PORT=${STATS_PORT:-8484}
ADMIN_SRCS=${ADMIN_SRCS:-0.0.0.0/0}

# 설정 파일 생성
if [ ! -z "$ADMIN_SRCS" ]; then
    cidrs=$(echo $ADMIN_SRCS | tr "," "\n")

    for cidr in $cidrs; do
        echo "$cidr" >> admin.txt
    done
fi


if [ ! -z "$WHITELIST_SRCS" ]; then
    cidrs=$(echo $WHITELIST_SRCS | tr "," "\n")

    for cidr in $cidrs; do
        echo "$cidr" >> whitelist.txt
    done
fi

if [ ! -z "$BLACKLIST_SRCS" ]; then
    cidrs=$(echo $BLACKLIST_SRCS | tr "," "\n")

    for cidr in $cidrs; do
        echo "$cidr" >> blacklist.txt
    done
fi

cat base.cfg > haproxy.cfg
echo >> haproxy.cfg

list=$(echo $MAPPINGS | tr "," "\n")

for mapping in $list; do
    writeMapping $mapping
done

sed -i "s#\$STATS_PORT#$STATS_PORT#g" haproxy.cfg
sed -i "s#\$MAX_CONN#$MAX_CONN#g" haproxy.cfg

echo "generated config"

cat haproxy.cfg

echo "-------------------------------------------"

haproxy -f haproxy.cfg &

child=$! 
wait "$child"