#!/bin/bash

gsutil cp /data/redis-bkup/dump.rdb.bkp gs://{{ .Values.redis.backup.gcsBucket }}/tokenbot-backup/dump.rdb.bkp