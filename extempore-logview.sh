#!/bin/bash

echo http://{172.17.8.101,172.17.8.102,172.17.8.103}:8000/logs | xargs -P 10 -n 1 curl

exit 0
