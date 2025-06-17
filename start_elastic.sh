#!/bin/bash

echo "docker compose ElasticSearch and Kibana"
cd ./ElasticSearch
docker compose up -d

if [ $? -eq 0 ]; then
    echo "ElasticSearch container has started"
else
    echo "Failed to start ElasticSearch container"
fi