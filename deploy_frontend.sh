#!/bin/bash

# Ensure environment variables are available (if needed)
# echo "VM Username: $1"
# echo "Frontend VM Private IP: $2"
# echo "Image Repository: $3"
# echo "Image Tag: $4" # Note: ACR name is not needed for Docker Hub

VM_USERNAME=$1
FRONTEND_VM_PRIVATE_IP=$2
IMAGE_REPOSITORY=$3
IMAGE_TAG=$4
CONTAINER_NAME="my-web-app-container" # Or whatever you named your container

echo "Connecting to frontend VM: ${FRONTEND_VM_PRIVATE_IP}"
ssh -o StrictHostKeyChecking=no ${VM_USERNAME}@${FRONTEND_VM_PRIVATE_IP} << EOF
  echo "Pulling Docker image from Docker Hub: ${IMAGE_REPOSITORY}:${IMAGE_TAG}"
  # For public Docker Hub images, no authentication is typically needed
  # If your image is private on Docker Hub, you'll need to add a docker login step here
  docker pull ${IMAGE_REPOSITORY}:${IMAGE_TAG} || { echo "Error: Docker pull failed"; exit 1; }

  echo "Stopping existing container: ${CONTAINER_NAME}"
  docker stop ${CONTAINER_NAME} || true # Stop if running

  echo "Removing existing container: ${CONTAINER_NAME}"
  docker rm ${CONTAINER_NAME} || true  # Remove if exists

  echo "Running new container: ${CONTAINER_NAME}"
  docker run -d --name ${CONTAINER_NAME} -p 80:3000 ${IMAGE_REPOSITORY}:${IMAGE_TAG} || { echo "Error: Docker run failed"; exit 1; }

  echo "Deployment to ${FRONTEND_VM_PRIVATE_IP} completed."
EOF

