### simple-haproxy-image

대충 env만 조정해서 쓸 수 있도록


#### env

| name | description | examples |
| ---- | ----------- | -------- |
| MAX_CONN | haproxy max conn | 10000 |
| STATS_PORT | haproxy stats port | 8484 |
| ADMIN_SRCS | stats 에 접속 가능하도록 할 cidr | 1.1.1.1/32,2.2.2.0/24 |
| WHITELIST_SRCS | whitelist cidr | 1.1.1.1/32,2.2.2.0/24 |
| BLACKLIST_SRCS | blacklist cidr, whitelist가 있으면 동작 안함 | 1.1.1.1/32,2.2.2.0/24 |
| MAPPING | frontend와 backend의 mapping | frontendport1:backendip1:backendport1,frontendport2:backendip2:backendport2 |