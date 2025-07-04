﻿# Nightmarket_Analysis
本專案以Nightmarket專案蒐集的評論資料為基礎，目標判斷評論是否為水軍留言。  
整合BERT Tokenizer、Hadoop HDFS、Spark MLlib 與 Elasticsearch，搭配Kibana實現大數據評論的分類與視覺化。

---

## 叢集架構說明
本專案使用Docker Compose模擬Hadoop與Spark叢集，主要組件配置如下：

- Hadoop Namenode
負責管理HDFS的metadata，協調資料的儲存與存取位置。

- Hadoop Datanode(s)
實際存放HDFS資料的節點，支援多個節點以提供資料分散與容錯。

- Spark Master
負責叢集資源管理與工作排程。

- Spark Worker(s)
執行實際的Spark任務，與Master協同工作，支援多個Worker以提高計算效能。

以上節點皆透過Docker容器運行，並在docker-compose.yaml 中配置網路與資源，模擬真實叢集環境。

## 技術堆疊（Tech Stack）

| 元件                        | 說明                              |
|-----------------------------|----------------------------------|
| **Python**                  | 程式語言                          |
| **Poetry**                  | Python套件管理與環境隔離           |
| **Docker / Docker Compose** | 部署Hadoop、Spark、Elasticsearch服務 |
| **HuggingFace Transformers**| BERT Tokenizer與Embedding       |
| **Apache Hadoop HDFS**      | 分散式資料存儲                     |
| **Apache Spark**            | 分散式資料處理與機器學習            |
| **Spark MLlib**             | 分散式機器學習庫，支援大規模資料的模型訓練與預測|
| **Jupyter**                 | 執行評論分詞（Tokenizer）、模型訓練與預測 |
| **Elasticsearch**           | 評論資料索引與查詢                  |
| **Kibana**                  | 資料視覺化與Dashboard             |

---

## 啟動方式

### 1. 環境需求

- Python 3.12+
- Hadoop 3.4.1 
- Spark 3.5.5
- Elasticsearch & Kibana

### 2. 使用poetry管理套件

- poetry.lock
- pyproject.toml


### 3. 啟動Hadoop與Spark叢集

bash ./build_base_image.sh

bash ./start_cluster.sh

### 4. 啟動Elasticsearch與Kibana

bash ./start_elastic.sh

## 專案流程

1. **資料預處理與向量化**  
   利用BERT Tokenizer將評論文字轉為固定長度向量（CLS 向量），分批處理並儲存成Parquet格式。

2. **分散式資料存儲**  
   將向量化的評論資料存入Hadoop HDFS，提供高效的儲存與存取，供Spark進行平行運算與分析。

3. **模型訓練與預測**  
   利用Spark MLlib分別訓練Logistic Regression、Random Forest、Linear SVM與GBTClassifier等模型，並比較其在訓練集與測試集上的AUC、Accuracy、Precision、Recall與 F1-score(詳模型表現總覽表)。根據評估結果，選擇泛化能力最佳的Linear SVM模型，對所有評論進行分類預測。

4. **資料索引與查詢**  
   將預測結果與評論資料一併上傳至Elasticsearch，實現快速全文搜尋及分類查詢。

5. **資料視覺化**  
   利用Kibana建立Dashboard，展示水軍評論分佈、時間趨勢及關鍵字分析。

## 模型表現總覽表

| 指標             | Logistic Regression | Random Forest | Linear SVM | GBT Classifier |
|------------------|---------------------|----------------|-------------|----------------|
| **Train AUC**        | 0.9969              | 0.9995         | 0.9908      | 0.9997         |
| **Test AUC**         | 0.9831              | 0.9465         | 0.9814      | 0.9523         |
| **Train Accuracy**   | 0.9804              | 0.9949         | 0.9634      | 0.9975         |
| **Test Accuracy**    | 0.9390              | 0.8672         | 0.9350      | 0.8821         |
| **Train Precision**  | 0.9787              | 0.9929         | 0.9567      | 0.9970         |
| **Test Precision**   | 0.9423              | 0.8650         | 0.9299      | 0.8920         |
| **Train Recall**     | 0.9845              | 0.9976         | 0.9750      | 0.9982         |
| **Test Recall**      | 0.9533              | 0.9136         | 0.9603      | 0.9065         |
| **Train F1-score**   | 0.9804              | 0.9949         | 0.9634      | 0.9975         |
| **Test F1-score**    | 0.9390              | 0.8663         | 0.9347      | 0.8819         |
| **Summary**          | 穩定泛化            | 過擬合         | 穩定泛化    | 過擬合         |
