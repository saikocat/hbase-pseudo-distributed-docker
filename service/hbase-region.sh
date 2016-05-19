#!/usr/bin/with-contenv sh
exec s6-applyuidgid -u 999 -g 999 hbase regionserver start
