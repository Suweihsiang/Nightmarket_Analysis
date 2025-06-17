#!/bin/bash

echo "docker compose hadoop and spark"
cd ./Hadoop_Spark
docker compose up -d

if [ $? -eq 0 ]; then
    echo "Hadoop and Spark Container has started"
else
    echo "Failed to start Hadoop and Spark container"
fi