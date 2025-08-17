#!/bin/sh
set -e

# Start runit supervisor for services under /etc/service
/usr/bin/runsvdir -P /etc/service &
RUNSVDIR_PID=$!

term_handler() {
  # Gracefully stop all services
  for s in /etc/service/*; do
    [ -d "$s" ] || continue
    /sbin/sv stop "$s" || true
  done
  # Signal runsvdir to exit and wait for it
  kill -HUP "$RUNSVDIR_PID" 2>/dev/null || true
  wait "$RUNSVDIR_PID"
  exit 0
}

trap term_handler TERM INT
wait "$RUNSVDIR_PID"
