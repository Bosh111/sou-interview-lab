#!/bin/bash

CONTAINER_NAME="Ping_Pong"
IMAGE_NAME="ealen/echo-server"

start_container() {
  local node=$1
  vagrant ssh $node -c "docker pull $IMAGE_NAME && docker run -d -p 3000:80 --name $CONTAINER_NAME $IMAGE_NAME"
}

stop_container() {
  local node=$1
  vagrant ssh $node -c "docker stop $CONTAINER_NAME > /dev/null && docker rm $CONTAINER_NAME > /dev/null"
}

cleanup() {
  echo "Stopping and removing containers on Ping and Pong"
  stop_container "ping" > /dev/null
  stop_container "pong" > /dev/null
  echo "Containers stopped :)"
  exit 0
}

# Set up trap to catch SIGINT (Ctrl + C) and run the cleanup function
trap cleanup SIGINT

while true; do
  echo "Starting container on node ping"
  start_container "ping"
  echo "Started container on ping"
  sleep 15

  echo "Stopping container on node ping"
  stop_container "ping"
  echo "Container stopped"

  echo "Starting container on node pong"
  start_container "pong"
  echo "Started container on pong"
  sleep 15

  echo "Stopping container on node pong"
  stop_container "pong"
  echo "Container stopped"
done
