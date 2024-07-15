#!/bin/bash

CONTAINER_NAME="Ping_Pong"
IMAGE_NAME="ealen/echo-server"

start_container() {
  local node=$1
  vagrant ssh $node -c "docker pull $IMAGE_NAME && docker run -d -p 3000:80 --name $CONTAINER_NAME $IMAGE_NAME"
}

stop_container() {
  local node=$1
  vagrant ssh $node -c "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
}

cleanup() {
  echo "Stopping and removing containers on Ping and Pong"
  stop_container "Ping"
  stop_container "Pong"
  exit 0
}

# Set up trap to catch SIGINT (Ctrl + C) and run the cleanup function
trap cleanup SIGINT

while true; do
  echo "Starting container on Ping"
  start_container "Ping"
  sleep 60

  echo "Stopping container on Ping"
  stop_container "Ping"

  echo "Starting container on Pong"
  start_container "Pong"
  sleep 60

  echo "Stopping container on Pong"
  stop_container "Pong"
done

