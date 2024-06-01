#!/bin/bash

# Check if the PID file exists
if [ -f server.pid ]; then
  # Read the PID and kill the process
  kill -TERM $(cat server.pid)
  echo "Server stopped"
  # Remove the PID file
  rm server.pid
else
  echo "No server PID file found"
fi
