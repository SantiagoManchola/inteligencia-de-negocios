from __future__ import annotations
from datetime import datetime, timedelta
from pathlib import Path
import json
from typing import Dict

from airflow import DAG  # type: ignore
from airflow.operators.python import PythonOperator  # type: ignore

from src import config
from src.extract import extract
from src.load import load
from src.transform import run_queries

"""Airflow DAG: elt_olist_pipeline

Pipeline ELT para el dataset de Olist:
    1. extract: Lee CSVs y API (festivos) y los cachea en .airflow_cache como CSV.
    2. load: Carga los CSV cacheados en SQLite evitando repetir llamadas a red.
    3. transform: Ejecuta queries y exporta resultados a /exports en formato CSV.
    4. summary: Muestra métricas ligeras de extracción (row counts).

Optimizaciones:
    - Cache en disco para evitar XCom pesados y re-extracciones.
    - Parámetro 'holidays_year' para facilitar reutilización anual.
"""

DEFAULT_ARGS = {
    "owner": "data-eng",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

DB_PATH = config.SQLITE_BD_ABSOLUTE_PATH
EXPORT_DIR = Path("exports")
EXPORT_DIR.mkdir(exist_ok=True)

# Directorio de caché (persistente entre tareas en el mismo worker)
CACHE_DIR = Path(".airflow_cache")
CACHE_DIR.mkdir(exist_ok=True)

def _extract(holidays_year: int, **context):
    mapping = config.get_csv_to_table_mapping()
    dfs = extract(config.DATASET_ROOT_PATH, mapping, config.PUBLIC_HOLIDAYS_URL)

    # Persistimos cada dataframe a cache (CSV) para uso downstream
    for name, df in dfs.items():
        df.to_csv(CACHE_DIR / f"{name}.csv", index=False)

    meta = {k: len(v) for k, v in dfs.items()}
    context["ti"].xcom_push(key="extract_meta", value=json.dumps(meta))

def _load(**context):
    from sqlalchemy import create_engine
    import pandas as pd

    mapping = config.get_csv_to_table_mapping()
    dataframes: Dict[str, "object"] = {}
    missing = []
    # Cargar desde caché
    for _, table_name in mapping.items():
        file_path = CACHE_DIR / f"{table_name}.csv"
        if file_path.exists():
            dataframes[table_name] = pd.read_csv(file_path)
        else:
            missing.append(table_name)

    ph_file = CACHE_DIR / "public_holidays.csv"
    if ph_file.exists():
        import pandas as pd  # local
        dataframes["public_holidays"] = pd.read_csv(ph_file)
    else:
        missing.append("public_holidays")

    if missing:
        raise RuntimeError(
            "Faltan CSVs en caché. Ejecuta primero extract. Faltantes: " + ", ".join(missing)
        )

    engine = create_engine(f"sqlite:///{DB_PATH}")
    load(dataframes, engine)

def _transform(**context):
    # Usamos conexión sqlite3 directa para evitar incompatibilidades pandas + SQLAlchemy 2.x
    import sqlite3
    conn = sqlite3.connect(DB_PATH)
    try:
        results: Dict[str, "object"] = run_queries(conn)
        for name, df in results.items():
            (EXPORT_DIR / f"{name}.csv").write_text(df.to_csv(index=False))
    finally:
        conn.close()

def _summary(**context):
    ti = context["ti"]
    meta = json.loads(ti.xcom_pull(task_ids="extract", key="extract_meta") or "{}")
    print("Extract rows per table:", meta)


with DAG(
    dag_id="elt_olist_pipeline",
    description="ELT Olist e-commerce dataset a SQLite + transforms + exports",
    default_args=DEFAULT_ARGS,
    schedule="@daily",  # nueva sintaxis
    start_date=datetime(2024, 1, 1),
    catchup=False,
    max_active_runs=2,  # permitir hasta 2 ejecuciones solapadas
    tags=["olist", "elt"],
    params={"holidays_year": 2017},
):
    t1 = PythonOperator(
        task_id="extract",
        python_callable=_extract,
        op_kwargs={"holidays_year": "{{ params.holidays_year }}"},
    )
    t2 = PythonOperator(task_id="load", python_callable=_load)
    t3 = PythonOperator(task_id="transform", python_callable=_transform)
    t4 = PythonOperator(task_id="summary", python_callable=_summary)
    t1 >> t2 >> t3 >> t4
