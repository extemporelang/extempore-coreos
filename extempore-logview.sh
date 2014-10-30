#!/bin/bash

: ${EXTEMPORE_HOSTS:="172.17.8.101 172.17.8.102"}
CURL_PIDS=""

for host in $EXTEMPORE_HOSTS
do
    curl http://$host:8000/logs & CURL_PIDS="$! $CURL_PIDS"
done

echo "kill this shell, or run kill $CURL_PIDS to kill the curl processes"

exit 0
