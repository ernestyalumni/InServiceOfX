#!/bin/bash

# Global variables
DOCKER_IMAGE_NAME="langchain-local-nvidia-python-24.03"

# Reads ARCH and PTX values from local text file, typically in the same
# (sub)directory as this script and named nvidia_compute_capabilities.txt.
read_compute_capabilities()
{
  local file_path="$1"
  local arch_value=$(grep '^ARCH=' "$file_path" | cut -d '=' -f 2)
  local ptx_value=$(grep '^PTX=' "$file_path" | cut -d '=' -f 2)

  echo "$arch_value" "$ptx_value"
}

# You must run this in the directory the this script is in because it needs to
# find the Dockerfile.

build_docker_image()
{
  # Path to nvidia_compute_capabilities.txt file; the hard assumption is made
  # that it'll be in the exact same (sub)directory as this file.
  local capabilities_file="$(dirname "$0")/nvidia_compute_capabilities.txt"

  # Read ARCH and PTX values.
  read -r ARCH_VALUE PTX_VALUE < <(read_compute_capabilities \
    "$capabilities_file")

  echo "Current directory: $(pwd)"
  cd ../ || { echo "Failed to change directory to '../'"; exit 1; }

  # Builds from Dockerfile in this directory.
  docker build \
    --build-arg ARCH="$ARCH_VALUE" \
    --build-arg PTX="$PTX_VALUE" \
    -t "$DOCKER_IMAGE_NAME" \
    -f LangchainLocal/Dockerfile .
}

main()
{
  cat Dockerfile.header \
    Dockerfile.base \
    Dockerfile.langchain \
    > Dockerfile

  build_docker_image
}

main "$@"
