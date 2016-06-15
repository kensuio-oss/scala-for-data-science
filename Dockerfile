FROM andypetrella/spark-notebook-demo:master-2.0.0-preview

# Data Fellas
MAINTAINER Data Fellas info@data-fellas.guru

USER root

ENV HOME /root

ENV NOTEBOOKS_DIR /root/spark-notebook/notebooks/scala-ds

ENV ADD_JARS /root/spark-notebook/lib/common.common-0.7.0-SNAPSHOT-scala-2.10.6-spark-2.0.0-preview-hadoop-2.2.0-with-hive-with-parquet.jar

ADD notebooks /root/spark-notebook/notebooks/scala-ds

WORKDIR /root/demo-base