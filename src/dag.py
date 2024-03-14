from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024,1,1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retries_delay': timedelta(minutes=1)
}

@dag(
    dag_id='postgres_to_snowflake',
    default_args=default_args,
    description='Carga de dados incremental do Banco de Dados Relacional (Postgres) para o ambiente analítico no Snowflake.',
    schedule_interval=timedelta(days=1),
    catchup=False
)
def postgres_to_snowflake_load():
    table_names = ['veiculos', 'estados', 'cidades', 'concessionarias', 'vendedores', 'clientes', 'vendas']

    for t in table_names:

        @task(task_id=f'get_max_id_{t}')
        def get_max_primary_key(t:str):
            with SnowflakeHook(Snowflake_conn_id='snowflake').get_conn() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(f'''
                                SELECT MAX(ID_{t})
                                FROM {t}
                                   ''')
                    max_id = cursor.fetchone()[0]
                    return max_id if max_id is not None else 0