#!/bin/sh

# Download flink
fetch http://apache.mirrors.spacedump.net/flink/flink-1.10.0/flink-1.10.0-bin-scala_2.11.tgz
tar -xf flink-1.10.0-bin-scala_2.11.tgz
mv flink-1.10.0 /usr/local/flink
cd /usr/local/flink
mkdir -p ./plugins/s3-fs-presto
cp ./opt/flink-s3-fs-presto-1.10.0.jar ./plugins/s3-fs-presto/

# Configure to use external IP for flink
ip_addr=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2)
sed -i -e 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: '$ip_addr'/g' conf/flink-conf.yaml

cat <<EOF > ./bin/start-node.sh
#!/usr/bin/env bash
/usr/local/flink/bin/jobmanager.sh start $ip_addr 8081
/usr/local/flink/bin/taskmanager.sh start
EOF

cat <<EOF > ./bin/stop-node.sh
#!/usr/bin/env bash
/usr/local/flink/bin/jobmanager.sh stop
/usr/local/flink/bin/taskmanager.sh stop
EOF

chmod +x ./bin/start-node.sh
chmod +x ./bin/stop-node.sh

# Setup flink rc.d script
fetch -o /usr/local/etc/rc.d/flink https://raw.githubusercontent.com/martenlindblad/iocage-plugin-apache-flink/master/usr/local/etc/rc.d/flink
sysrc flink_enable=YES 