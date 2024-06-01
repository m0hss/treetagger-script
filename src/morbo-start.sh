#!/bin/bash

# Start the server and save the PID
morbo server.pl &
echo $! > server.pid
echo "Server started with PID $(cat server.pid)"
