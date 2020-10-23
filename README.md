# Haproxy wrong redirect based on HTTP health check

Haproxy seems to not redirect traffic based on HTTP health check when it is subjected to configuration reload

## Step to reproduce:

### Deployed configuration:

- A simple configuration with two backend and HTTP healthcheck based on HTTP return code.
- Two nginx containers
    - One returning always 503 status code
    - One returning always 200 status code

### Wrong redirect in action

```
# build and start containers
docker-compose build && docker-compose up -d

# perform curl on haproxy endpoint
while true; do date && curl http://127.0.0.1:3000 && sleep 1 && echo ""; done

# perform in the meantime reload on haproxy configuration
docker-compose exec haproxy /reload.sh
```

```
# haproxy.cfg
# ...
frontend ftd
    bind 0.0.0.0:3000
    mode tcp
    option tcplog
    maxconn 20000
    timeout client 6h0m0s
    default_backend bkd

backend bkd
    mode tcp
    balance roundrobin
    option httpchk GET /
    http-check expect status 200
    timeout check 10000ms
    timeout server 21600000ms
    timeout tunnel 21600000ms
    timeout connect 5000ms

    default-server inter 5000ms fall 3 on-marked-down shutdown-sessions
        server srv_0 nginx200:80  check port 80
        server srv_1 nginx503:80  check port 80
```

```
$> while true; do date && curl http://127.0.0.1:3000 && sleep 1 && echo ""; done
Ven 23 oct 2020 13:29:33 CEST
200 OK
Ven 23 oct 2020 13:29:34 CEST
200 OK
Ven 23 oct 2020 13:29:35 CEST
200 OK
Ven 23 oct 2020 13:29:36 CEST
503 KO
Ven 23 oct 2020 13:29:37 CEST
200 OK
Ven 23 oct 2020 13:29:38 CEST
200 OK
Ven 23 oct 2020 13:29:39 CEST
503 KO^C
```

```
$> docker-compose exec haproxy /reload.sh
Fri Oct 23 11:29:34 UTC 2020
reload
Fri Oct 23 11:29:36 UTC 2020
reload
Fri Oct 23 11:29:38 UTC 2020
reload^C
```

