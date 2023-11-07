#!/bin/bash

redis-cli -h {{ .Values.redis.backup.redisHost }} SAVE
redis-cli -h {{ .Values.redis.backup.redisHost }} --rdb /data/redis-bkup/dump.rdb.bkup GET dump.rdb