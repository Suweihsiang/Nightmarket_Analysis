FROM openjdk:11-slim

# 設定環境變數
ENV SPARK_VERSION=3.5.5 \
    HADOOP_VERSION=3.4.1 \
    SPARK_HOME=/opt/spark \
    HADOOP_HOME=/opt/hadoop \
    HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root \
    YARN_RESOURCEMANAGER_USER=root \
    YARN_NODEMANAGER_USER=root \
    JAVA_HOME=/usr/local/openjdk-11 \
    PYSPARK_PYTHON=python3
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
    PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH

# 複製 Hadoop 和 Spark 壓縮檔案
COPY ./spark-3.5.5-bin-hadoop3.tgz /opt/
COPY ./hadoop-3.4.1.tar.gz /opt/

RUN apt-get update && apt-get install -y \
    python3-pip openssh-server git curl wget bash && \
    apt-get clean && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip install --upgrade pip && \
    pip install poetry

# 解壓 Spark 和 Hadoop
RUN tar -xzf /opt/spark-3.5.5-bin-hadoop3.tgz -C /opt/ \
    && tar -xzf /opt/hadoop-3.4.1.tar.gz -C /opt/ \
    && rm /opt/spark-3.5.5-bin-hadoop3.tgz /opt/hadoop-3.4.1.tar.gz \
    && mv /opt/hadoop-3.4.1 /opt/hadoop \
    && mv /opt/spark-3.5.5-bin-hadoop3 /opt/spark

# 複製 poetry 檔案到容器
COPY poetry.lock pyproject.toml .
RUN touch README.md
RUN poetry install --no-root

# 複製 Hadoop 配置檔案及 entrypoint.sh 腳本到容器內
COPY ./hadoop_config/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh
COPY ./hadoop_config/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY ./hadoop_config/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml
COPY ./hadoop_config/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xml
COPY ./hadoop_config/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml
COPY ./hadoop_config/spark-defaults.conf /opt/spark/conf/
COPY entrypoint.sh /opt/hadoop/entrypoint.sh
RUN chmod +x /opt/hadoop/entrypoint.sh && \
    echo "export JAVA_HOME=/usr/local/openjdk-11" >> /opt/hadoop/etc/hadoop/hadoop-env.sh && \
    chmod -R 755 /opt/hadoop/etc/hadoop /opt/spark/conf

# 設定容器啟動時執行 entrypoint.sh
ENTRYPOINT ["/opt/hadoop/entrypoint.sh"]