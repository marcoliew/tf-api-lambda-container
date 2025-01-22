#!/bin/bash

#  docker build -t my-lambda-function --build-arg FILE_NAME=s3 .
#  docker run -p 9000:8080 my-lambda-function
#  curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" -H "Content-Type: application/json"



# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Please provide a file name as an argument."
  echo "Usage: ./docker.sh file_name"
  exit 1
fi

# Set the argument as a variable
FILE_NAME=$1

# Build the Docker image with the specified file name
docker build -t ${FILE_NAME}-lambda-function --build-arg FILE_NAME=${FILE_NAME} .

# Run the Docker container in detached mode
docker run -d -p 9000:8080 --name ${FILE_NAME}-container-$(date +%s) ${FILE_NAME}-lambda-function

# Test the Lambda function with curl
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" -H "Content-Type: application/json"

# Output logs from the container for visibility
#docker logs $(docker ps -q --filter "name=${FILE_NAME}-container")


