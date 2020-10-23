from ubuntu:focal

COPY reload.sh /reload.sh

RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:vbernat/haproxy-2.2 \
    && apt-get update \
    && apt-get install -y haproxy \
    && mkdir /run/haproxy/ \
    && chown haproxy:haproxy /run/haproxy/ \
    && chmod +x /reload.sh

COPY haproxy.cfg /etc/haproxy/haproxy.cfg

CMD /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -S /run/haproxy-master.sock

# while true; do curl http://127.0.0.1:3000 && sleep 1 && echo ""; done
