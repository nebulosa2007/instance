#!/bin/bash
LOG_DIR="/var/log/nginx"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

for logfile in "$LOG_DIR"/*.log; do
    [ -e "$logfile" ] || continue
    base=$(basename "$logfile")
    rotated="$LOG_DIR/${base%.*}.$DATE.log"
    mv "$logfile" "$rotated"
    gzip "$rotated"
done

PIDFILE="/var/run/nginx.pid"
if [ -f "$PIDFILE" ]; then
    kill -USR1 $(cat "$PIDFILE")
fi

find "$LOG_DIR" -type f -name "*.log.gz" -mtime +30 -delete
