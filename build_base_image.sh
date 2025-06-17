#!/bin/bash

IMAGE_NAME="hadoop-spark-base"
TAG="latest"

echo "Build $IMAGE_NAME:$TAG"
cd ./Hadoop_Spark
docker build -t $IMAGE_NAME:$TAG .

if [ $? -eq 0 ]; then
    echo "Build $IMAGE_NAME:$TAG successfully"
else
    echo "Failed to build $IMAGE_NAME:$TAG"
    exit 1
fi