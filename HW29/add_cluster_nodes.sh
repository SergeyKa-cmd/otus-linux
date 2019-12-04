#!/bin/bash

ipaddr=$(hostname -i | awk ' { print $1 } ')

if [ -z "$REFRESH_INTERVAL" ]; then
        export REFRESH_INTERVAL=1m
fi


if [ -z "$NODE_COUNT" ]; then
        export NODE_COUNT=3
fi


waiting_proxysql() {
        status=255
        while [ $status -gt 0 ]; do
            echo Waiting proxysql
            sleep 2s
            `2>/dev/null echo "" > /dev/tcp/127.0.0.1/6032 || exit 1`
            status=$?
        done
}

waiting_discovery_service() {
        status=255
        while [ $status -gt 0 ]; do
            echo Waiting discovery service
            sleep 2s
            status=$(curl -s $DISCOVERY_SERVICE 2>/dev/null 1>/dev/null; echo $?)
        done
        return $(curl -s http://$DISCOVERY_SERVICE/v2/keys/pxc-cluster/$CLUSTER_NAME/ | jq -r '.node.nodes[]?.key' | awk -F'/' '{print $(NF)}' | wc -l)
}

add_nodes() {
        for i in $(curl http://$DISCOVERY_SERVICE/v2/keys/pxc-cluster/$CLUSTER_NAME/ | jq -r '.node.nodes[]?.key' | awk -F'/' '{print $(NF)}')
        do
                echo $i 
                mysql -h $i -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON *.* TO '$MYSQL_PROXY_USER'@'$ipaddr' IDENTIFIED BY '$MYSQL_PROXY_PASSWORD'"
                mysql -h 127.0.0.1 -P6032 -uadmin -padmin -e "INSERT INTO mysql_servers (hostgroup_id, hostname, port, max_replication_lag) VALUES (0, '$i', 3306, 20);"
        done
        mysql -h 127.0.0.1 -P6032 -uadmin -padmin -e "INSERT INTO mysql_users (username, password, active, default_hostgroup, max_connections) VALUES ('$MYSQL_PROXY_USER', '$MYSQL_PROXY_PASSWORD', 1, 0, 200);"
        mysql -h 127.0.0.1 -P6032 -uadmin -padmin -e "LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK; LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;"
}  

# refreshing nodes
while [ 0 -eq 0 ] ; do
  waiting_proxysql
  nodes=0
  while [ $nodes -lt $NODE_COUNT ]; do
    waiting_discovery_service
    nodes=$?
  done 
  add_nodes
  #echo waiting next update
  sleep $REFRESH_INTERVAL
done
