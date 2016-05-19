**HBASE Pseudo Distributed with**:
* Alpine - 3.3 
* syslog
* DNS - dnsmasq 
* Service user - app 
* Exposed volume `/data/hbase`

# Build Instruction
```
$ docker build -t saikocat/hbase-pseudo-distributed:1.1.5 .
```

# Run Instruction
```
$ docker run -t \
   -p 2181:2181 \
   -p 16000:16000 \
   -p 16010:16010 \
   -p 16020:16020 \ 
   -p 16030:16030 \
   -p 9090:9090 \
   --name hbase-pd \
   -h hbase.local \
   -i saikocat/hbase-standalone:v1.1.5 \
   /bin/bash
```

# Sample code to connect inside the container
```scala
// 'hbase.local' is the hostname we set for our container 
// and inside the host's /etc/hosts
val config = HBaseConfiguration.create()
config.set("hbase.zookeeper.quorum", "hbase.local");
config.set("hbase.zookeeper.property.clientPort", "2181");
config.set("hbase.master", "hbase.local:16000");
config.set("hbase.client.retries.number", "3");  // default 35
config.set("hbase.rpc.timeout", "10000");  // default 60 secs
config.set("hbase.rpc.shortoperation.timeout", "5000"); // default 10 secs

val connection = ConnectionFactory.createConnection(config)
HBaseAdmin.checkHBaseAvailable(config);
```

# Future Development
If there is more interest in other version (1.2.x and CDH), I will follow up accordingly. Right now, I am concentrating on stable version only. Branch in GitHub repo will reflect each branch (1.1.x-stable, 1.2.x-unstable, CDH) accordingly.
