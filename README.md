# Project 01 Cases study ETL process
> E-Commerce Data Pipeline

Hi! this is the first of several projects we're going to be working on during this course.

You will be expected to finish this on your own, but you can use the available channels on Discord to ask questions and help others. Please read the entire notebook before starting, this will give you a better idea of what you need to accomplish.

## The Business problem

You are working for one of the largest E-commerce sites in Latam and they requested the Data Science team to analyze company data to understand better their performance in specific metrics during the years 2016-2018.

They are two main areas they want to explore, those are **Revenue** and *Delivery*.

Basically, they would like to understand how much revenue by year they got, which were the most and less popular product categories, and the revenue by state. On the other hand, it's also important to know how well the company is delivering the products sold in time and form to their users. For example, seeing how much takes to deliver a package depends on the month and the difference between the estimated delivery date and the real one.

## About the data

You will consume and use data from two sources.

The first one is a Brazilian e-commerce public dataset of orders made at the Olist Store, provided as CSV files. This is real commercial data that has been anonymized. The dataset has information on 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allow viewing orders from multiple dimensions: from order status, price, payment, and freight performance to customer location, product attributes and finally reviews written by customers. You will find an image showing the database schema at `images/data_schema.png`.

Dataset availability:
- The `dataset/` folder (CSV source files) is versioned in this repository so you can clone and run immediately.
- If for some reason the folder is missing (e.g. you performed a sparse/partial clone) you can download it from this [link](https://drive.google.com/file/d/1Ofm0tZ30KVXhXRp7LpTkzd_VaJg9Peno/view?usp=sharing), extract the `dataset` folder from the `.zip` file and place it into the project root.
See `ASSIGNMENT.md`, section **Project Structure** to validate its location.

The second source is a public API: https://date.nager.at. You will use it to retrieve information about Brazil's Public Holidays and correlate that with certain metrics about the delivery of products.

## Technical aspects

Because the team knows the data will come from different sources and formats, also, probably you will have to provide these kinds of reports on a monthly or annual basis. They decided to build a data pipeline (ELT) they can execute from time to time to produce the results.

The technologies involved are:
- Python as the main programming language
- Pandas for consuming data from CSVs files
- Requests for querying the public holidays API
- SQLite as a database engine
- SQL as the main language for storing, manipulating, and retrieving data in our Data Warehouse
- Matplotlib and Seaborn for the visualizations
- Jupyter notebooks to make the report an interactive way

## Instalation

Before install requirements package, please create a virtual environment for the project on the project folder

```Create a virtual environment 
$ python -m venv myenvname

''' Activate the virtual environment
''' macOS and Linux
$ source myenvname/bin/activate
''' windows
$ myenvmyenvname\Scripts\activate
```
A `requirements.txt` file is provided with all the needed Python libraries for running this project. For installing the dependencies just run:

```console
$ pip install -r requirements.txt
```


*Note:* We encourage you to install those inside a virtual environment.

## Code Style

Following a style guide keeps the code's aesthetics clean and improves readability, making contributions and code reviews easier. Automated Python code formatters make sure your codebase stays in a consistent style without any manual work on your end. If adhering to a specific style of coding is important to you, employing an automated to do that job is the obvious thing to do. This avoids bike-shedding on nitpicks during code reviews, saving you an enormous amount of time overall.

We use [Black](https://black.readthedocs.io/) for automated code formatting in this project, you can run it with:

```console
$ black --line-length=88 .
```

Wanna read more about Python code style and good practices? Please see:
- [The Hitchhiker’s Guide to Python: Code Style](https://docs.python-guide.org/writing/style/)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)

## Tests

We provide unit tests along with the project that you can run and check from your side the code meets the minimum requirements of correctness needed to approve. To run just execute:

```console
$ pytest tests/
```

If you want to learn more about testing Python code, please read:
- [Effective Python Testing With Pytest](https://realpython.com/pytest-python-testing/)
- [The Hitchhiker’s Guide to Python: Testing Your Code](https://docs.python-guide.org/writing/tests/)

## Orquestación con Apache Airflow

El proyecto incluye un DAG (`elt_olist_pipeline`) en `airflow_home/dags/elt_olist_dag.py` que automatiza el flujo ELT.

Flujo de tareas:
1. extract: lee CSVs + API de festivos y guarda cada DataFrame como CSV cacheado en `.airflow_cache/`.
2. load: ingesta a SQLite (`olist.db`) usando únicamente los archivos cacheados.
3. transform: ejecuta consultas (SQL y pandas) y exporta resultados a `exports/`.
4. summary: imprime métricas ligeras (conteos) vía XCom.

Ventajas implementadas:
- Evita pasar DataFrames grandes por XCom.
- Reutiliza código existente en `src/` sin duplicación de lógica.
- Parámetro `holidays_year` expuesto (por defecto 2017) para futura reutilización.

### Configuración rápida (PowerShell / Windows)
Usa un entorno virtual separado para Airflow para no romper dependencias del proyecto principal.

```powershell
# Crear y activar entorno
python -m venv airflow_venv
airflow_venv\Scripts\Activate.ps1

# Instalar Airflow (ejemplo con constraints para Python 3.12)
pip install "apache-airflow==2.9.1" --constraint https://raw.githubusercontent.com/apache/airflow/constraints-2.9.1/constraints-3.12.txt

# Inicializar metadatos
airflow db init

# Crear usuario admin
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin

# Servidor web y scheduler (dos terminales)
airflow webserver -p 8080
airflow scheduler
```

Luego ingresa a http://localhost:8080 y habilita el DAG.

### Ejecución manual
```powershell
airflow dags trigger elt_olist_pipeline
```

Puedes sobreescribir parámetros al disparar:
```powershell
airflow dags trigger elt_olist_pipeline --conf '{"holidays_year": 2018}'
```

### Artefactos generados
- Base de datos: `olist.db`
- Resultados transformados: `exports/*.csv`
- Caché intermedio: `.airflow_cache/`

### Limpieza opcional
Puedes limpiar la caché si requieres una extracción fresca:
```powershell
Remove-Item .airflow_cache -Recurse -Force
```

### Notas
- Si `load` falla por archivos faltantes, ejecuta primero `extract`.
- El diseño actual sobrescribe tablas (`if_exists='replace'`), adecuado para fines académicos.
- Para producción podrías añadir: sensores de disponibilidad de archivos, verificación de esquemas y retención de historiales.

## Cómo clonar y ejecutar Airflow en otro PC


1. Entorno separado para Airflow (recomendado)
```powershell
python -m venv airflow_venv
airflow_venv\Scripts\Activate.ps1
pip install "apache-airflow==2.9.1" --constraint https://raw.githubusercontent.com/apache/airflow/constraints-2.9.1/constraints-3.12.txt
airflow db init
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin
```
2. Copiar/Validar DAG
	- Confirmar que `airflow_home/dags/elt_olist_dag.py` está presente (si no, copiarlo desde el repo original a esa ruta).

3. Iniciar servicios
```powershell
airflow webserver -p 8080
airflow scheduler
```
	Abrir http://localhost:8080, habilitar DAG `elt_olist_pipeline` y disparar un run.

4. Resultados
	- Base: `olist.db`
	- Exports: `exports/*.csv` (se regeneran en cada run)

5. Actualizar credenciales Airflow (opcional)
```powershell
airflow users reset-password -u admin
```

6. Limpiezas
```powershell
Remove-Item .airflow_cache -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item exports\*.csv -Force -ErrorAction SilentlyContinue
```

7. (Opcional) Excluir dataset del control de versiones
	- Actualmente los CSV en `dataset/` están versionados para facilitar la reproducción académica.
	- Si prefieres no incluirlos (por tamaño o políticas), añade de nuevo la regla `dataset/*.csv` a `.gitignore` y ejecuta:
	  ```powershell
	  git rm -r --cached dataset
	  git commit -m "chore: stop tracking dataset csvs"
	  ```
	- Luego puedes documentar cómo obtenerlos usando el enlace indicado arriba.

Resumen: clonas, pones dataset, instalas dependencias (dos entornos), inicializas Airflow, creas usuario, ejecutas DAG, revisas `exports/`.
