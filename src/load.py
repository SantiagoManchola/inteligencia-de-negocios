from typing import Dict, Any
from pandas import DataFrame
from sqlalchemy.engine import Engine


def load(data_frames: Dict[str, DataFrame], database: Any):
    """Load DataFrames into the SQLite database.

    Acepta tanto un Engine de SQLAlchemy como una conexión DBAPI. Se usa
    raw_connection() cuando es un Engine para evitar el error de pandas
    con SQLAlchemy 2.x ("Engine object has no attribute 'cursor'").
    """
    # Obtener conexión compatible con pandas
    close_after = False
    conn = database
    try:
        if isinstance(database, Engine):
            # raw_connection devuelve objeto DBAPI con .cursor()
            conn = database.raw_connection()
            close_after = True

        for table_name, df in data_frames.items():
            df.to_sql(table_name, con=conn, if_exists="replace", index=False)
            # Forzar commit tras cada tabla para asegurar persistencia en SQLite
            try:
                conn.commit()  # type: ignore[attr-defined]
            except Exception:
                pass
    finally:
        if close_after:
            try:
                conn.close()  # type: ignore[attr-defined]
            except Exception:
                pass