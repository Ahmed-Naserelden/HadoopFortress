#!/bin/bash

if [ "$HBASE_ROLE" = "master" ]; then
  echo "Starting HBase Master..."
  exec $HBASE_HOME/bin/hbase master start
elif [ "$HBASE_ROLE" = "regionserver" ]; then
  echo "Starting HBase RegionServer..."
  exec $HBASE_HOME/bin/hbase regionserver start
else
  echo "Unknown role: $HBASE_ROLE"
  exit 1
fi