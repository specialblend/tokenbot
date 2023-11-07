#!/bin/bash

gsutil cp /data/redis-dump/dump.rdb.bkp gs://{{ .Values.redis.backup.gcsBucket }}/tokenbot-backup/dump.rdb.bkp