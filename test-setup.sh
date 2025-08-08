#!/bin/bash

# Assuming setup.sh is in the same directory as test-setup.sh
SCRIPT_NAME="setup.sh"

# Check if setup.sh exists
if [ ! -f "$SCRIPT_NAME" ]; then
  echo "Error: $SCRIPT_NAME not found!"
  exit 1
fi

# Run the setup.sh script in the specified containers as root
# for IMAGE in alpine:latest; do
for IMAGE in alpine:latest; do
# for IMAGE in alpine:latest archlinux:latest ubuntu:latest debian:latest; do
  echo "Running $SCRIPT_NAME in $IMAGE container as root..."

  # Docker command to run the script, install sudo if needed
  docker run -it --rm -v $PWD:/app -w /app $IMAGE /bin/sh -c "
    if ! command -v sudo &> /dev/null; then
      if [ '$IMAGE' = 'alpine:latest' ]; then
        apk update && apk add --no-cache doas
      elif [ '$IMAGE' = 'archlinux:latest' ]; then
        pacman -Sy --noconfirm --needed sudo
      else
        apt update && apt install -y sudo
      fi
    fi
    chmod +x /app/$SCRIPT_NAME
    ./$SCRIPT_NAME --full
  "
done