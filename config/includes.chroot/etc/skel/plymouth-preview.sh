#!/bin/bash

if [ ! $( id -u ) -eq 0 ]; then
  echo Must be run as root
  exit
fi

DURATION=$1
if [ $# -ne 1 ]; then
  DURATION=5
fi

plymouthd
plymouth --show-splash
for ((I=0; I<$DURATION; I++)); do
  plymouth --update=test$I;
  sleep 1;
  done;
plymouth quit
