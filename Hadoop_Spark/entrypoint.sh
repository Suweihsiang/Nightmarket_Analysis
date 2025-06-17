#!/bin/bash

# 確保 Hadoop 資料夾存在
mkdir -p /opt/hadoop_data/namenode
mkdir -p /opt/hadoop_data/datanode

# 設定權限，避免 DataNode 啟動失敗
chmod -R 777 /opt/hadoop_data/namenode /opt/hadoop_data/datanode

# 設定 Hadoop 的配置檔案位置
HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

# 如果是 Namenode 節點，格式化並啟動 Namenode
if [ "$NODE_TYPE" = "namenode" ]; then
    echo "Starting HDFS Namenode..."
    
    # 格式化 NameNode
    if [ ! -d /opt/hadoop_data/name/current ]; then
        echo "Formatting HDFS NameNode..."
        hdfs namenode -format -force -nonInteractive
    fi
    
    # 啟動 Hadoop namenode secondarynamenode
    hdfs --daemon start namenode
    hdfs --daemon start secondarynamenode

    # 等待 daemon 起來（可選加個 sleep 讓服務先啟動穩定）
    sleep 5

    mkdir -p /opt/hadoop_data/name
    chmod -R 777 /opt/hadoop_data/name

    # 自動建立 Spark 需要的目錄（如有需要可加更多）
    echo "Creating HDFS directories for Spark..."
    hdfs dfs -mkdir -p /spark-events
    hdfs dfs -chmod -R 777 /spark-events

    hdfs dfs -mkdir -p /workspace/data/spark-warehouse
    hdfs dfs -chmod -R 777 /workspace/data/spark-warehouse

    # 保持容器運行
    tail -f /dev/null

# 如果是 DataNode 節點，啟動 DataNode
elif [ "$NODE_TYPE" = "datanode" ]; then
    echo "Starting HDFS Datanode..."
    
    # 啟動 datanode
    hdfs --daemon start datanode

    mkdir -p /opt/hadoop_data/data
    chmod -R 777 /opt/hadoop_data/data

    # 保持容器運行
    tail -f /dev/null

# 如果是 Spark master 節點，啟動 Spark master
elif [ "$NODE_TYPE" = "spark-master" ]; then
    echo "Starting Spark Master..."

    # 啟動 Spark master
    start-master.sh
    
    # 保持容器運行
    tail -f /dev/null


# 如果是 Spark Worker 節點，啟動 Spark Worker
elif [ "$NODE_TYPE" = "spark-worker" ]; then
    echo "Starting Spark Worker..."
    
    # 啟動 Spark worker
    start-worker.sh ${SPARK_MASTER_URL:-spark://spark-master:7077}
    
    # 保持容器運行
    tail -f /dev/null

elif [ "$NODE_TYPE" = "jupyter" ]; then
    poetry run jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token=''
fi

else
    echo "Error: NODE_TYPE must be 'namenode', 'datanode', 'spark-master' or 'spark-worker'"
    exit 1
fi