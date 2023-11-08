#!/bin/bash

redis-cli -h {{ .Values.redis.backup.redisHost }} SAVE
redis-cli -h {{ .Values.redis.backup.redisHost }} --rdb /data/redis-dump/dump.rdb.bkp GET dump.rdb