# Guía Completa del Proyecto ETL - E-Commerce Olist

## 📋 Índice

1. [Descripción General del Proyecto](#descripción-general-del-proyecto)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)
4. [Fases del Pipeline ETL](#fases-del-pipeline-etl)
5. [Configuración e Instalación](#configuración-e-instalación)
6. [Explicación Detallada de Cada Componente](#explicación-detallada-de-cada-componente)
7. [Orquestación con Apache Airflow](#orquestación-con-apache-airflow)
8. [Pruebas y Validación](#pruebas-y-validación)
9. [Visualizaciones](#visualizaciones)
10. [Ejecución Paso a Paso](#ejecución-paso-a-paso)

---

## 📊 Descripción General del Proyecto

Este proyecto implementa un **pipeline de datos ETL (Extract, Transform, Load)** para analizar datos de comercio electrónico de la empresa brasileña **Olist**. El objetivo es ayudar a una de las plataformas de e-commerce más grandes de Latinoamérica a analizar su rendimiento en métricas clave durante los años 2016-2018.

### 🎯 Objetivos del Negocio

- **Análisis de Ingresos**: Entender cuántos ingresos se generaron por año, categorías más y menos populares, ingresos por estado
- **Análisis de Entregas**: Evaluar qué tan bien la empresa está entregando productos a tiempo, tiempos de entrega según el mes, diferencias entre fecha estimada y real de entrega

### 📈 Métricas Principales

- Ingresos por año, mes y estado
- Top 10 de categorías con mayor/menor ingresos
- Diferencias en fechas de entrega
- Relación entre peso y costo de envío
- Análisis de pedidos vs días festivos

---

## 🗂️ Estructura del Proyecto

```
assignmentProyect01/
├── 📄 README.md                    # Documentación principal
├── 📄 ASSIGNMENT.md                # Instrucciones del proyecto
├── 📄 requirements.txt             # Dependencias Python
├── 📄 ETLProject.ipynb             # Notebook principal para análisis
├── 📄 olist.db                     # Base de datos SQLite generada
├──
├── 📁 dataset/                     # Datos fuente (CSV)
│   ├── olist_customers_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   └── product_category_name_translation.csv
├──
├── 📁 src/                         # Código fuente principal
│   ├── __init__.py
│   ├── config.py                   # Configuraciones del proyecto
│   ├── extract.py                  # Módulo de extracción de datos
│   ├── load.py                     # Módulo de carga a base de datos
│   ├── transform.py                # Módulo de transformación y consultas
│   └── plots.py                    # Módulo de visualizaciones
├──
├── 📁 queries/                     # Consultas SQL
│   ├── delivery_date_difference.sql
│   ├── global_ammount_order_status.sql
│   ├── revenue_by_month_year.sql
│   ├── revenue_per_state.sql
│   ├── top_10_least_revenue_categories.sql
│   ├── top_10_revenue_categories.sql
│   └── real_vs_estimated_delivered_time.sql
├──
├── 📁 tests/                       # Pruebas unitarias
│   ├── test_extract.py
│   ├── test_transform.py
│   └── query_results/              # Resultados esperados
├──
├── 📁 airflow_home/                # Configuración de Airflow
│   ├── airflow.cfg
│   └── dags/
│       └── elt_olist_dag.py        # DAG de Airflow
├──
├── 📁 images/                      # Imágenes y gráficos
├── 📁 exports/                     # Resultados exportados (CSV)
└── 📁 myenvname/                   # Entorno virtual Python
```

---

## 🛠️ Tecnologías Utilizadas

| Tecnología             | Propósito                          | Versión |
| ---------------------- | ---------------------------------- | ------- |
| **Python**             | Lenguaje principal de programación | 3.8+    |
| **Pandas**             | Manipulación y análisis de datos   | Última  |
| **SQLite**             | Base de datos para Data Warehouse  | -       |
| **SQLAlchemy**         | ORM y conexión a base de datos     | 2.x     |
| **Requests**           | Consumo de APIs REST               | Última  |
| **Matplotlib/Seaborn** | Visualización de datos             | Última  |
| **Jupyter**            | Notebooks interactivos             | Última  |
| **Apache Airflow**     | Orquestación de pipelines          | 2.9.1   |
| **Pytest**             | Framework de pruebas               | Última  |
| **Black**              | Formateo automático de código      | Última  |

---

## 🔄 Fases del Pipeline ETL

### 1. **EXTRACT (Extracción)**

- **Fuente 1**: Archivos CSV del dataset de Olist (datos locales)
- **Fuente 2**: API pública de días festivos de Brasil (https://date.nager.at)
- **Resultado**: DataFrames en memoria con datos limpios

### 2. **LOAD (Carga)**

- **Destino**: Base de datos SQLite (`olist.db`)
- **Proceso**: Carga de todos los DataFrames como tablas
- **Estrategia**: Reemplazar tablas existentes (`if_exists='replace'`)

### 3. **TRANSFORM (Transformación)**

- **Herramienta**: Consultas SQL personalizadas
- **Proceso**: Análisis y agregación de datos
- **Resultado**: Métricas de negocio calculadas

---

## ⚙️ Configuración e Instalación

### Paso 1: Crear Entorno Virtual

```bash
# Crear entorno virtual
python -m venv myenvname

# Activar entorno (macOS/Linux)
source myenvname/bin/activate

# Activar entorno (Windows)
myenvname\Scripts\activate
```

### Paso 2: Instalar Dependencias

```bash
pip install -r requirements.txt
```

### Paso 3: Verificar Instalación

```bash
# Ejecutar pruebas
pytest tests/

# Formatear código
black --line-length=88 .
```

---

## 🔍 Explicación Detallada de Cada Componente

### 📁 `src/config.py`

Archivo de configuración central que define:

- Rutas de archivos y directorios
- URLs de APIs
- Mapeo de archivos CSV a nombres de tablas
- Configuraciones de base de datos

```python
# Ejemplos de configuración
DATASET_ROOT_PATH = "dataset"
SQLITE_BD_ABSOLUTE_PATH = "olist.db"
PUBLIC_HOLIDAYS_URL = "https://date.nager.at/api/v3/publicholidays"
CSV_TABLE_MAPPING = {
    "olist_customers_dataset.csv": "olist_customers",
    "olist_orders_dataset.csv": "olist_orders",
    # ... más mapeos
}
```

### 📁 `src/extract.py`

**Funciones principales:**

#### `get_public_holidays(public_holidays_url, year)`

- **Propósito**: Obtiene días festivos de Brasil desde API externa
- **Entrada**: URL de API y año específico
- **Proceso**:
  1. Hace petición HTTP a la API
  2. Convierte respuesta JSON a DataFrame
  3. Elimina columnas innecesarias (`types`, `counties`)
  4. Convierte columna `date` a formato datetime
- **Salida**: DataFrame con días festivos

#### `extract(csv_folder, csv_table_mapping, public_holidays_url)`

- **Propósito**: Función principal de extracción
- **Proceso**:
  1. Lee todos los archivos CSV usando pandas
  2. Crea diccionario de DataFrames
  3. Obtiene días festivos para 2017
  4. Combina todos los datos
- **Salida**: Diccionario con todos los DataFrames listos para carga

### 📁 `src/load.py`

**Función principal:**

#### `load(data_frames, database)`

- **Propósito**: Carga DataFrames en base de datos SQLite
- **Características**:
  - Compatible con SQLAlchemy Engine y conexiones DBAPI
  - Usa `raw_connection()` para evitar problemas con SQLAlchemy 2.x
  - Reemplaza tablas existentes (`if_exists='replace'`)
  - Hace commit después de cada tabla
- **Gestión de errores**: Manejo robusto de conexiones y commits

### 📁 `src/transform.py`

**Componentes principales:**

#### `QueryEnum`

Enumeración que define todas las consultas disponibles:

- `DELIVERY_DATE_DIFFERECE`
- `GLOBAL_AMMOUNT_ORDER_STATUS`
- `REVENUE_BY_MONTH_YEAR`
- `REVENUE_PER_STATE`
- `TOP_10_LEAST_REVENUE_CATEGORIES`
- `TOP_10_REVENUE_CATEGORIES`
- `REAL_VS_ESTIMATED_DELIVERED_TIME`

#### Funciones de consulta

Cada consulta tiene su función dedicada que:

1. Lee el archivo SQL correspondiente
2. Ejecuta la consulta usando `pandas.read_sql`
3. Retorna un `QueryResult` con nombre de consulta y resultado

### 📁 `queries/` - Consultas SQL

#### `revenue_by_month_year.sql`

**Propósito**: Calcula ingresos mensuales por año (2016-2018)
**Estructura**:

- `month_no`: Número de mes (01-12)
- `month`: Nombre corto del mes (Jan, Feb, etc.)
- `Year2016`, `Year2017`, `Year2018`: Ingresos por año

**Lógica SQL**:

```sql
-- Combina órdenes con pagos
-- Agrupa por mes y año
-- Usa PIVOT para mostrar años como columnas
-- Rellena con 0.00 cuando no hay datos
```

#### `top_10_revenue_categories.sql`

**Propósito**: Top 10 categorías con mayores ingresos
**Incluye**: Traducción de nombres de categorías al inglés

#### `delivery_date_difference.sql`

**Propósito**: Analiza diferencias entre fechas estimadas y reales de entrega
**Métricas**: Días de diferencia, porcentajes de entregas a tiempo

### 📁 `src/plots.py`

**Funciones de visualización:**

- `plot_revenue_by_month_year()`: Gráfico de líneas de ingresos mensuales
- `plot_top_10_revenue_categories()`: Gráfico de barras de categorías top
- `plot_delivery_date_difference()`: Histograma de diferencias de entrega
- `plot_freight_value_weight_relationship()`: Scatter plot peso vs costo envío
- Y más visualizaciones especializadas...

---

## 🌊 Orquestación con Apache Airflow

### 📁 `airflow_home/dags/elt_olist_dag.py`

#### Estructura del DAG

```python
DAG: elt_olist_pipeline
├── Task 1: extract_task
├── Task 2: load_task
├── Task 3: transform_task
└── Task 4: summary_task
```

#### Flujo de Tareas

**1. extract_task**

- Ejecuta función de extracción
- Cachea resultados en `.airflow_cache/` como archivos CSV
- Evita pasar DataFrames pesados por XCom

**2. load_task**

- Lee archivos CSV cacheados
- Carga datos en SQLite (`olist.db`)
- Depende de: `extract_task`

**3. transform_task**

- Ejecuta todas las consultas SQL
- Exporta resultados a `exports/*.csv`
- Depende de: `load_task`

**4. summary_task**

- Muestra métricas de resumen
- Cuenta registros por tabla
- Depende de: `extract_task`

#### Ventajas del Diseño

- **Cache inteligente**: Evita re-extracciones innecesarias
- **Reutilización de código**: Usa módulos existentes de `src/`
- **Parámetros configurables**: `holidays_year` personalizable
- **Gestión de errores**: Robust error handling en cada tarea

### Configuración de Airflow

#### Instalación (Entorno Separado)

```bash
# Crear entorno específico para Airflow
python -m venv airflow_venv
source airflow_venv/bin/activate

# Instalar Airflow con constraints
pip install "apache-airflow==2.9.1" --constraint https://raw.githubusercontent.com/apache/airflow/constraints-2.9.1/constraints-3.12.txt

# Inicializar metadatos
airflow db init

# Crear usuario administrador
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin
```

#### Ejecución

```bash
# Terminal 1: Servidor web
airflow webserver -p 8080

# Terminal 2: Scheduler
airflow scheduler

# Acceder a: http://localhost:8080
```

#### Ejecución Manual

```bash
# Ejecutar DAG completo
airflow dags trigger elt_olist_pipeline

# Con parámetros personalizados
airflow dags trigger elt_olist_pipeline --conf '{"holidays_year": 2018}'
```

---

## 🧪 Pruebas y Validación

### Estructura de Pruebas

```
tests/
├── test_extract.py          # Pruebas de extracción
├── test_transform.py        # Pruebas de transformación
└── query_results/           # Resultados esperados
    ├── delivery_date_difference.json
    ├── revenue_by_month_year.json
    └── ...más archivos de referencia
```

### Tipos de Pruebas

#### Pruebas de Extracción (`test_extract.py`)

- Valida conexión a API de días festivos
- Verifica formato correcto de DataFrames
- Comprueba limpieza y transformación de datos
- Testa manejo de errores de red

#### Pruebas de Transformación (`test_transform.py`)

- Ejecuta cada consulta SQL
- Compara resultados con archivos de referencia JSON
- Valida estructura de datos de salida
- Verifica cálculos de métricas de negocio

### Ejecución de Pruebas

```bash
# Ejecutar todas las pruebas
pytest tests/

# Pruebas específicas
pytest tests/test_extract.py
pytest tests/test_transform.py

# Con verbosidad
pytest tests/ -v

# Con reporte de cobertura
pytest tests/ --cov=src/
```

---

## 📊 Visualizaciones

### Notebook Principal: `ETLProject.ipynb`

#### Estructura del Notebook

1. **Configuración inicial**: Imports y setup de base de datos
2. **Fase de Extracción**: Ejecución de funciones de extracción
3. **Fase de Carga**: Carga de datos en SQLite
4. **Fase de Transformación**: Ejecución de consultas SQL
5. **Visualizaciones**: Gráficos interactivos con matplotlib/seaborn

#### Tipos de Gráficos Generados

**1. Gráficos de Ingresos**

- Ingresos mensuales por año (líneas temporales)
- Ingresos por estado (mapas de calor)
- Top 10 categorías más/menos rentables (barras)

**2. Análisis de Entregas**

- Distribución de diferencias en fechas de entrega
- Tiempo real vs estimado de entrega
- Relación peso-costo de envío

**3. Análisis Temporal**

- Pedidos por día con marcadores de días festivos
- Tendencias estacionales

### Generación de Imágenes

Las visualizaciones se guardan automáticamente en:

```
images/
├── revenue_by_month_year.png
├── top_10_revenue_categories.png
├── delivery_date_difference.png
├── freight_value_weight_relationship.png
└── orders_per_day_and_holidays.png
```

---

## 🚀 Ejecución Paso a Paso

### Método 1: Ejecución Manual (Recomendado para Desarrollo)

#### Paso 1: Preparación del Entorno

```bash
# Navegar al directorio del proyecto
cd /Users/santiagomanchola/Desktop/Universidad/2025B/Inteligencia\ de\ negocios/assignmentProyect01

# Activar entorno virtual
source myenvname/bin/activate

# Verificar instalación
python --version
pip list
```

#### Paso 2: Ejecución del Pipeline

```bash
# Opción A: Ejecutar notebook completo
jupyter notebook ETLProject.ipynb

# Opción B: Ejecutar módulos individuales
python -c "
from src.extract import extract
from src.load import load
from src.transform import run_queries
from src.config import *
import pandas as pd
from sqlalchemy import create_engine

# Extract
data = extract(DATASET_ROOT_PATH, CSV_TABLE_MAPPING, PUBLIC_HOLIDAYS_URL)
print(f'Extracted {len(data)} tables')

# Load
engine = create_engine(f'sqlite:///{SQLITE_BD_ABSOLUTE_PATH}')
load(data, engine)
print('Data loaded to SQLite')

# Transform
results = run_queries(engine)
print(f'Executed {len(results)} queries')
"
```

#### Paso 3: Validación

```bash
# Ejecutar pruebas
pytest tests/ -v

# Verificar archivos generados
ls -la olist.db
ls -la exports/
ls -la images/
```

### Método 2: Ejecución con Airflow (Recomendado para Producción)

#### Paso 1: Configurar Airflow

```bash
# Activar entorno de Airflow
source airflow_venv/bin/activate

# Verificar configuración
airflow config list
airflow dags list
```

#### Paso 2: Ejecutar DAG

```bash
# Ejecutar desde línea de comandos
airflow dags trigger elt_olist_pipeline

# O desde interfaz web
# 1. Abrir http://localhost:8080
# 2. Buscar DAG "elt_olist_pipeline"
# 3. Activar toggle
# 4. Click en "Trigger DAG"
```

#### Paso 3: Monitoreo

```bash
# Ver estado de ejecución
airflow dags state elt_olist_pipeline $(date +%Y-%m-%d)

# Ver logs de tareas
airflow tasks log elt_olist_pipeline extract_task $(date +%Y-%m-%d)
airflow tasks log elt_olist_pipeline load_task $(date +%Y-%m-%d)
airflow tasks log elt_olist_pipeline transform_task $(date +%Y-%m-%d)
```

### Método 3: Ejecución de Componentes Individuales

#### Solo Extracción

```bash
pytest tests/test_extract.py -v
```

#### Solo Transformación

```bash
pytest tests/test_transform.py -v
```

#### Consulta Específica

```bash
python -c "
from src.transform import query_revenue_by_month_year
from sqlalchemy import create_engine

engine = create_engine('sqlite:///olist.db')
result = query_revenue_by_month_year(engine)
print(result.result.head())
"
```

---

## 🔧 Solución de Problemas Comunes

### Error: "Module not found"

```bash
# Asegurar que estás en el directorio correcto
pwd
ls src/

# Verificar PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

### Error: "Database locked"

```bash
# Cerrar todas las conexiones a SQLite
rm -f olist.db-journal
```

### Error: "API timeout"

```bash
# Verificar conexión a internet
ping date.nager.at

# Aumentar timeout en src/extract.py
response = requests.get(url, timeout=30)
```

### Error: "Airflow DAG no aparece"

```bash
# Verificar ruta de DAGs
echo $AIRFLOW_HOME
ls $AIRFLOW_HOME/dags/

# Verificar sintaxis del DAG
python airflow_home/dags/elt_olist_dag.py
```

---

## 📈 Métricas de Éxito y Resultados Esperados

### Datos de Entrada

- **~100,000 órdenes** (2016-2018)
- **~50,000 clientes únicos**
- **~3,000 vendedores**
- **73 categorías de productos**
- **~27 estados de Brasil**

### Resultados Esperados

- Base de datos SQLite con 9+ tablas
- 7+ consultas SQL ejecutadas exitosamente
- 5+ visualizaciones generadas
- Todos los tests pasando (100% success rate)
- Pipeline completo en <10 minutos

### KPIs del Pipeline

- **Tiempo de extracción**: <2 minutos
- **Tiempo de carga**: <1 minuto
- **Tiempo de transformación**: <3 minutos
- **Cobertura de pruebas**: >90%
- **Calidad de datos**: 0 valores nulos en campos críticos

---

## 🎓 Aprendizajes y Mejores Prácticas

### Técnicas de ETL Aprendidas

1. **Extracción multi-fuente**: CSV + API REST
2. **Transformación con SQL**: Queries complejas y eficientes
3. **Carga incremental**: Estrategias de reemplazo vs append
4. **Orquestación**: Dependency management con Airflow
5. **Testing**: Pruebas automatizadas para pipelines de datos

### Mejores Prácticas Implementadas

- **Separación de responsabilidades**: Cada módulo tiene una función específica
- **Configuración centralizada**: Un solo lugar para todas las configuraciones
- **Gestión de errores**: Try-catch robusto en puntos críticos
- **Documentación**: Docstrings y comentarios explicativos
- **Versionado**: Control de versiones con git
- **Entornos virtuales**: Aislamiento de dependencias

### Código Limpio

- **PEP 8 compliance**: Formateo con Black
- **Type hints**: Anotaciones de tipos para mejor legibilidad
- **Nombres descriptivos**: Variables y funciones auto-explicativas
- **Funciones pequeñas**: Single responsibility principle
- **DRY principle**: No repetición de código

---

## 🚀 Extensiones Futuras

### Mejoras Técnicas

1. **Data Quality**: Implementar validaciones de calidad de datos
2. **Incremental Loading**: Carga incremental instead de full replace
3. **Data Lineage**: Tracking del origen y transformaciones de datos
4. **Monitoring**: Alertas y métricas de rendimiento del pipeline
5. **Scaling**: Migración a herramientas como Apache Spark para big data

### Mejoras de Negocio

1. **Real-time Analytics**: Stream processing para análisis en tiempo real
2. **ML Integration**: Modelos de machine learning para predicciones
3. **Dashboard Interactivo**: Herramientas como Tableau o Power BI
4. **Data Catalog**: Documentación automática de datasets
5. **Multi-tenant**: Support para múltiples clientes/regiones

### Infraestructura

1. **Containerización**: Docker para deployment consistente
2. **Cloud Migration**: AWS/GCP/Azure para escalabilidad
3. **CI/CD**: Pipeline de deployment automatizado
4. **Infrastructure as Code**: Terraform para gestión de recursos
5. **Data Lake**: Arquitectura moderna de datos para diferentes formatos

---

## 📚 Recursos Adicionales

### Documentación Técnica

- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Jupyter Notebook Documentation](https://jupyter-notebook.readthedocs.io/)

### Cursos y Tutoriales

- [Real Python - ETL Tutorials](https://realpython.com/search?q=etl)
- [DataCamp - Data Engineering Track](https://www.datacamp.com/tracks/data-engineer-with-python)
- [Coursera - Data Engineering Courses](https://www.coursera.org/search?query=data%20engineering)

### Herramientas Complementarias

- **DBeaver**: IDE visual para bases de datos
- **Postman**: Testing de APIs
- **Git**: Control de versiones
- **Docker**: Containerización
- **VS Code**: Editor de código recomendado

---

## ✅ Checklist de Finalización

### Desarrollo Completado

- [ ] Todos los TODOs implementados en `src/extract.py`
- [ ] Todos los TODOs implementados en `src/load.py`
- [ ] Todas las consultas SQL completadas en `queries/`
- [ ] Notebook `ETLProject.ipynb` ejecutado sin errores
- [ ] DAG de Airflow funcionando correctamente

### Testing y Calidad

- [ ] Todas las pruebas pasando (`pytest tests/`)
- [ ] Código formateado con Black (`black --line-length=88 .`)
- [ ] No warnings o errors en la ejecución
- [ ] Documentación actualizada

### Entregables

- [ ] Base de datos `olist.db` generada correctamente
- [ ] Archivos de exportación en `exports/` creados
- [ ] Visualizaciones en `images/` generadas
- [ ] Cache de Airflow funcionando (`.airflow_cache/`)

### Documentación

- [ ] README.md revisado y actualizado
- [ ] Esta guía completa creada y revisada
- [ ] Comentarios en código son claros y útiles
- [ ] Instrucciones de instalación verificadas

---

**¡Felicidades!** 🎉 Has completado un proyecto completo de Data Engineering con un pipeline ETL robusto, pruebas automatizadas, orquestación con Airflow y visualizaciones de datos. Este proyecto demuestra competencias clave en el análisis de datos empresariales y ingeniería de datos moderna.

---

_Última actualización: Septiembre 2025_
_Proyecto: ETL E-Commerce Olist - Inteligencia de Negocios_
_Universidad: [Tu Universidad]_
_Curso: Inteligencia de Negocios_
