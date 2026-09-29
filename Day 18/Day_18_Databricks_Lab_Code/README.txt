DAY 18 DATABRICKS LAB CODE
Use the companion lab guide for workspace, permission and compute setup.
Extract this archive and import the seven IPYNB notebooks through Workspace.
Use an approved supported LTS ML Runtime on compatible Dedicated compute.
Set catalog and schema widgets in EVERY notebook and run Configuration first.
Run 00_setup once before the other notebooks. Run cells in order.
Notebooks 01 through 06 can then be studied in filename order.
The fixtures do not depend on Day 17 tables or external data downloads.
Setup overwrites named day18 tables in your assigned schema.
SQL files use training_lab.student_01 as the example namespace: replace it.
Optional layout demonstrations are in 02_layout_examples.sql.
Required Python libraries: pandas numpy matplotlib statsmodels prophet.
Spark ML examples require pyspark.ml from compatible Databricks compute.
Use the preflight import cell in Lab 2 and record the working versions.
Forecasting compares candidates on validation before a frozen final test.
Model scores and query timings must be measured in the delivery environment.
Data are invented for teaching. No deployed endpoint or GPU is required.
