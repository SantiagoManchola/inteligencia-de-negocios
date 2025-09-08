# Paso 5 con WSL2 y Airflow (Opción 1)

Guía rápida para levantar Airflow en WSL2 (Ubuntu) y ejecutar el pipeline como DAG.

## 1. Instalar WSL2 (si aún no lo tienes)
En PowerShell (Administrador):
```
wsl --install -d Ubuntu
```
Reinicia si lo pide. Abre "Ubuntu" desde el menú Inicio y crea tu usuario.

## 2. Paquetes base dentro de Ubuntu
```
sudo apt update && sudo apt install -y python3.11-venv git
```

## 3. Clonar el repositorio dentro de Ubuntu
```
mkdir -p ~/projects && cd ~/projects
# Usa tu fork si aplica
git clone https://github.com/SantiagoManchola/inteligencia-de-negocios.git
cd inteligencia-de-negocios
```
Asegúrate de copiar la carpeta `dataset/` si no está en el repo (o volver a descargarla) y que tenga los CSV.

## 4. Crear y activar entorno para Airflow
```
python3 -m venv airflow_venv
source airflow_venv/bin/activate
pip install --upgrade pip wheel setuptools
```

## 5. Instalar Airflow con constraints
```
AIRFLOW_VERSION=2.9.3
PY_VERSION=3.11
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VERSION}.txt"
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
```

## 6. Preparar estructura del proyecto para el DAG
Crea carpeta dags y un archivo `dags/elt_olist_dag.py` (ver sección 10 más abajo para el contenido sugerido) o copia el que tenías antes si aún lo conservas localmente.

```
mkdir -p dags
```

## 7. Exportar AIRFLOW_HOME (opcional personalizado)
```
export AIRFLOW_HOME="$(pwd)/airflow_home"
mkdir -p "$AIRFLOW_HOME"
```

## 8. Inicializar base de metadatos y usuario
```
airflow db migrate
airflow users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com \
  --password admin
```

## 9. Ejecutar servicios
En una terminal:
```
airflow scheduler
```
En otra terminal (mismo venv):
```
airflow webserver -p 8080
```
Abrir: http://localhost:8080 (admin / admin)

## 10. Contenido ejemplo para `dags/elt_olist_dag.py`
```python
from __future__ import annotations
from datetime import datetime, timedelta
from pathlib import Path
import json
from typing import Dict

from airflow import DAG
from airflow.operators.python import PythonOperator

# Imports del proyecto
from src import config
from src.extract import extract
from src.load import load
from src.transform import run_queries

DEFAULT_ARGS = {
    "owner": "data-eng",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

DB_PATH = config.SQLITE_BD_ABSOLUTE_PATH
EXPORT_DIR = Path("exports")
EXPORT_DIR.mkdir(exist_ok=True)

def _extract(**context):
    mapping = config.get_csv_to_table_mapping()
    dfs = extract(config.DATASET_ROOT_PATH, mapping, config.PUBLIC_HOLIDAYS_URL)
    meta = {k: len(v) for k, v in dfs.items()}
    context["ti"].xcom_push(key="extract_meta", value=json.dumps(meta))

def _load(**context):
    from sqlalchemy import create_engine
    mapping = config.get_csv_to_table_mapping()
    dfs = extract(config.DATASET_ROOT_PATH, mapping, config.PUBLIC_HOLIDAYS_URL)
    engine = create_engine(f"sqlite:///{DB_PATH}")
    load(dfs, engine)

def _transform(**context):
    from sqlalchemy import create_engine
    engine = create_engine(f"sqlite:///{DB_PATH}")
    results: Dict[str, "object"] = run_queries(engine)
    for name, df in results.items():
        (EXPORT_DIR / f"{name}.csv").write_text(df.to_csv(index=False))

def _summary(**context):
    ti = context["ti"]
    meta = json.loads(ti.xcom_pull(task_ids="extract", key="extract_meta") or "{}")
    print("Extract rows per table:", meta)

with DAG(
    dag_id="elt_olist_pipeline",
    default_args=DEFAULT_ARGS,
    schedule_interval="@daily",
    start_date=datetime(2024,1,1),
    catchup=False,
    max_active_runs=1,
    tags=["olist", "elt"],
):
    t1 = PythonOperator(task_id="extract", python_callable=_extract)
    t2 = PythonOperator(task_id="load", python_callable=_load)
    t3 = PythonOperator(task_id="transform", python_callable=_transform)
    t4 = PythonOperator(task_id="summary", python_callable=_summary)
    t1 >> t2 >> t3 >> t4
```

## 11. Verificar DAG
En la UI, activar el DAG y lanzar un run manual. Revisa los logs de cada tarea.

## 12. Notas
- WSL2 comparte red con Windows: http://localhost:8080 funciona directo.
- Si cambias código en `src/`, reinicia el scheduler o espera al siguiente parse.
- Para limpiar: detener procesos y borrar `airflow_home/` si deseas reiniciar.

## 13. Script opcional de arranque rápido (crear archivo run_airflow.sh)
```bash
#!/usr/bin/env bash
set -euo pipefail
export AIRFLOW_HOME="$(pwd)/airflow_home"
python3 -m venv airflow_venv
source airflow_venv/bin/activate
pip install --upgrade pip wheel setuptools
AIRFLOW_VERSION=2.9.3
PY_VERSION=3.11
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VERSION}.txt"
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
mkdir -p dags
# (coloca aquí creación/copia del DAG si no existe)
airflow db migrate
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin
exec airflow webserver -p 8080
```

Listo: con esto puedes cumplir el punto 5 usando WSL2.
