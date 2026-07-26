# PART 1
# =====================================================================
# DAG: Load Raw CSVs from GCS to Postgres (Bronze Layer)
# ---------------------------------------------------------------------
# Purpose : Load Airbnb, Census, and LGA mapping raw data
# Author  : Ngoc Bao Tran Nguyen
# Date    : 21/10/2025
# =====================================================================

import os
import logging
import requests
import pandas as pd
import numpy as np
import shutil
from datetime import datetime, timedelta
from psycopg2.extras import execute_values
from airflow import AirflowException
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import tempfile
import os

dag_default_args = {
    'owner': 'airflow',
    'start_date': datetime.now() - timedelta(days=2+4),
    'email': [],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'depends_on_past': False,
    'wait_for_downstream': False,
}

dag = DAG(
    dag_id='load_raw_into_postgres',
    default_args=dag_default_args,
    schedule_interval=None,
    catchup=True,
    max_active_runs=1,
    concurrency=5
)

AIRFLOW_DATA = "/home/airflow/gcs/data"
DIMENSIONS = AIRFLOW_DATA + "/dimensions/"

# ---------------- CONFIGURATION ---------------- #
#GCS_BUCKET = "australia-southeast1-bde-at-12fe3188-bucket"
#PG_CONN_ID = "postgres_default"
#BRONZE_SCHEMA = "bronze"
# ------------------------------------------------ #

# ---------------------------------------------------------------------
# Function: Load CSV from GCS to Postgres
# ---------------------------------------------------------------------
def import_load_airbnb_raw_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()

    #Check if file exists
    airbnb_file_path = DIMENSIONS + '05_2020.csv'
    if not os.path.exists(airbnb_file_path):
        logging.info("No 05_2020.csv file found.")
        return None

    # Generate dataframe by reading the CSV file
    df = pd.read_csv(airbnb_file_path)
    if len(df) > 0:
        col_names = df.columns
        values = df[col_names].to_dict('split')['data']
        logging.info(values)
        cols = ",".join([f'"{c}"' for c in df.columns])
        values = [tuple(x) for x in df.to_numpy()]
        insert_sql = f"""
                    INSERT INTO bronze.airbnb_raw({cols})
                    VALUES %s
        """
        result = execute_values(conn_ps.cursor(), insert_sql, values, page_size=len(df))
        conn_ps.commit()        

def import_load_go1_raw_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()

    #Check if file exists
    go1_file_path = DIMENSIONS + '2016Census_G01_NSW_LGA.csv'
    if not os.path.exists(go1_file_path):
        logging.info("No 2016Census_G01_NSW_LGA.csv file found.")
        return None

    # Generate dataframe by reading the CSV file
    df = pd.read_csv(go1_file_path)
    if len(df) > 0:
        col_names = df.columns
        values = df[col_names].to_dict('split')['data']
        logging.info(values)
        cols = ",".join([f'"{c}"' for c in df.columns])
        values = [tuple(x) for x in df.to_numpy()]
        insert_sql = f"""
                    INSERT INTO bronze.census_g01_raw({cols})
                    VALUES %s
        """
        result = execute_values(conn_ps.cursor(), insert_sql, values, page_size=len(df))
        conn_ps.commit()

def import_load_go2_raw_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()

    #Check if file exists
    go2_file_path = DIMENSIONS + '2016Census_G02_NSW_LGA.csv'
    if not os.path.exists(go2_file_path):
        logging.info("No 2016Census_G02_NSW_LGA.csv file found.")
        return None

    # Generate dataframe by reading the CSV file
    df = pd.read_csv(go2_file_path)
    if len(df) > 0:
        col_names = df.columns
        values = df[col_names].to_dict('split')['data']
        logging.info(values)
        cols = ",".join([f'"{c}"' for c in df.columns])
        values = [tuple(x) for x in df.to_numpy()]
        insert_sql = f"""
                    INSERT INTO bronze.census_g02_raw({cols})
                    VALUES %s
        """
        result = execute_values(conn_ps.cursor(), insert_sql, values, page_size=len(df))
        conn_ps.commit()

def import_load_suburb_raw_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()

    #Check if file exists
    suburb_file_path = DIMENSIONS + 'NSW_LGA_SUBURB.csv'
    if not os.path.exists(suburb_file_path):
        logging.info("No NSW_LGA_SUBURB.csv file found.")
        return None

    # Generate dataframe by reading the CSV file
    df = pd.read_csv(suburb_file_path)
    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
    if len(df) > 0:
        col_names = df.columns
        values = df[col_names].to_dict('split')['data']
        logging.info(values)
        cols = ",".join([f'"{c}"' for c in df.columns])
        values = [tuple(x) for x in df.to_numpy()]
        insert_sql = f"""
                    INSERT INTO bronze.lga_suburb_mapping_raw({cols})
                    VALUES %s
        """
        result = execute_values(conn_ps.cursor(), insert_sql, values, page_size=len(df))
        conn_ps.commit()

def import_load_code_raw_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()

    #Check if file exists
    code_file_path = DIMENSIONS + 'NSW_LGA_CODE.csv'
    if not os.path.exists(code_file_path):
        logging.info("No NSW_LGA_CODE.csv file found.")
        return None

    # Generate dataframe by reading the CSV file
    df = pd.read_csv(code_file_path)
    if len(df) > 0:
        col_names = df.columns
        values = df[col_names].to_dict('split')['data']
        logging.info(values)
        cols = ",".join([f'"{c}"' for c in df.columns])
        values = [tuple(x) for x in df.to_numpy()]
        insert_sql = f"""
                    INSERT INTO bronze.lga_code_mapping_raw({cols})
                    VALUES %s
        """
        result = execute_values(conn_ps.cursor(), insert_sql, values, page_size=len(df))
        conn_ps.commit()
# ---------------------------------------------------------------------
# DAG Operator Setup
# ---------------------------------------------------------------------
import_load_airbnb_raw = PythonOperator(
    task_id="import_load_airbnb_raw_id",
    python_callable=import_load_airbnb_raw_func,
    provide_context=True,
    dag=dag
)

import_load_go1_raw = PythonOperator(
    task_id="import_load_go1_raw_id",
    python_callable=import_load_go1_raw_func,
    provide_context=True,
    dag=dag
)

import_load_go2_raw = PythonOperator(
    task_id="import_load_go2_raw_id",
    python_callable=import_load_go2_raw_func,
    provide_context=True,
    dag=dag
)

import_load_suburb_raw = PythonOperator(
    task_id="import_load_suburb_raw_id",
    python_callable=import_load_suburb_raw_func,
    provide_context=True,
    dag=dag
)

import_load_code_raw = PythonOperator(
    task_id="import_load_code_raw_id",
    python_callable=import_load_code_raw_func,
    provide_context=True,
    dag=dag
)

import_load_airbnb_raw >> import_load_go1_raw >> import_load_go2_raw >> import_load_suburb_raw >> import_load_code_raw
# =====================================================================

# PART 3
# =====================================================================
# DAG: Load Airbnb Raw CSVs from GCS to Postgres
# ---------------------------------------------------------------------
# Purpose : Load Airbnb raw data
# Author  : Ngoc Bao Tran Nguyen
# Date    : 25/10/2025
# =====================================================================

import os
import logging
import requests
import pandas as pd
import numpy as np
import shutil
from datetime import datetime, timedelta
from psycopg2.extras import execute_values
from airflow import AirflowException
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.providers.google.cloud.transfers.gcs_to_local import GCSToLocalFilesystemOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import tempfile
import os
from google.cloud import storage
import re

dag_default_args = {
    'owner': 'airflow',
    'start_date': datetime.now() - timedelta(days=2+4),
    'email': [],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'depends_on_past': False,
    'wait_for_downstream': False,
}

# ---------------- CONFIGURATION ---------------- #

GCP_BUCKET = "australia-southeast1-bde-at-12fe3188-bucket"  
GCS_PREFIX = "data/dimensions"                              # Folder containing Airbnb CSVs
LOCAL_DIR = "/tmp/airbnb_load"                              # Local temporary directory
PG_CONN_ID = "postgres_default"                             # Airflow Postgres connection name
BRONZE_TABLE = "bronze.airbnb_raw" 
# ------------------------------------------------ #

# ---------------------------------------------------------------------
# Ensure local dir exists
# ---------------------------------------------------------------------
def ensure_local_dir():
    if os.path.exists(LOCAL_DIR):
        shutil.rmtree(LOCAL_DIR)
    os.makedirs(LOCAL_DIR)
    logging.info(f"Created clean local directory: {LOCAL_DIR}")

# ---------------------------------------------------------------------
# Download only airbnb CSV files from GCS
# ---------------------------------------------------------------------
def download_all_from_gcs():
    """Download airbnb .csv files from GCS_PREFIX into LOCAL_DIR"""
    client = storage.Client()
    bucket = client.bucket(GCP_BUCKET)
    blobs = bucket.list_blobs(prefix=GCS_PREFIX)

    pattern = re.compile(r"^\d{2}_\d{4}\.csv$")  # only files like 05_2020.csv
    count = 0

    for blob in blobs:
        filename = os.path.basename(blob.name)
        if pattern.match(filename):
            local_path = os.path.join(LOCAL_DIR, filename)
            blob.download_to_filename(local_path)
            count += 1
            logging.info(f"Downloaded {filename}")
        else: 
            logging.info("Skipped non-airbnb file {filename}")
    
    if count == 0:
        logging.warning("No Airbnb CSV files found.")
    else:
        logging.info(f"Downloaded {count} Airbnb CSV files.")

# ------------------------------------------------ #
# Load each CSV file into Postgres
# ------------------------------------------------ #
def import_load_airbnb_func(**kwargs):
    ps_pg_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn_ps = ps_pg_hook.get_conn()
    cur = conn_ps.cursor()

    csv_files = sorted([f for f in os.listdir(LOCAL_DIR) if f.endswith(".csv")])
    logging.info(f"Found {len(csv_files)} Airbnb CSVs to load.")

    for file_name in csv_files:
        file_path = os.path.join(LOCAL_DIR, file_name)
        logging.info(f"Processing file: {file_name}")

        try:
            month, year = file_name.replace(".csv", "").split("_")
        except Exception:
            logging.warning(f"Unexpected filename format: {file_name}")
            continue

         # Read data
        df = pd.read_csv(file_path)
        if df.empty:
            logging.warning(f"Skipping empty file: {file_name}")
            continue
        conn_ps.commit()

        # Insert new records
        cols = ",".join([f'"{c}"' for c in df.columns])
        insert_sql = f"INSERT INTO {BRONZE_TABLE} ({cols}) VALUES %s"
        execute_values(cur, insert_sql, df.values.tolist())
        conn_ps.commit()
        logging.info(f"Inserted {len(df)} rows from {file_name}")

    cur.close()
    conn_ps.close()
    logging.info("All monthly Airbnb files loaded successfully!")

# ------------------------------------------------ #
# DAG DEFINITION
# ------------------------------------------------ #
default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="load_airbnb_month_in_to_postgres",
    default_args=dag_default_args,
    schedule_interval=None,      # manual trigger
    catchup=True,
    tags=["bronze", "airbnb", "bde_at3"],
    max_active_runs=1,
    concurrency=5
) as dag:

    # Step 1: ensure local folder
    setup_dir = PythonOperator(
        task_id="setup_local_folder",
        python_callable=ensure_local_dir,
    )

    # Step 2: download all Airbnb monthly CSVs
    download_files = PythonOperator(
        task_id="download_airbnb_files",
        python_callable=download_all_from_gcs,
    )

    # Step 4: load data into Postgres
    load_airbnb = PythonOperator(
        task_id="load_airbnb_to_postgres",
        python_callable=import_load_airbnb_func,
    )

    setup_dir >> download_files >> load_airbnb


