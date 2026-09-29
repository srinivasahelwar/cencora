-- Replace student_01 with your assigned schema.
USE CATALOG training_lab;
USE SCHEMA student_01;

CREATE OR REPLACE TABLE day18_perf_clustered
USING DELTA CLUSTER BY (event_date, store_id)
AS SELECT * FROM day18_perf;
OPTIMIZE day18_perf_clustered;
DESCRIBE DETAIL day18_perf_clustered;

-- Separate small syntax demonstration only
CREATE OR REPLACE TABLE day18_partition_demo
USING DELTA PARTITIONED BY (month_start)
AS SELECT *, trunc(event_date, 'month') AS month_start
FROM day18_perf;
SHOW PARTITIONS day18_partition_demo;
