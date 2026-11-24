from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime


dag = DAG('custom_dag', description='Custom dag example', schedule_interval='*/1 * * * *', start_date=datetime(2025, 3, 6), catchup=False)


def print_hello():
    return ("Hello world!")

def my_operation():
    return ("This is my operation!")

dummy_task_1 = DummyOperator(
 task_id = 'dummy_task',
 retries = 0,
 dag = dag)
 
hello_task_2 = PythonOperator(
    task_id = 'hello_task', 
    python_callable = print_hello, 
    dag = dag)

operation_3 = PythonOperator(
    task_id = 'my_operation_task', 
    python_callable = my_operation, 
    dag = dag)


dummy_task_1 >> hello_task_2 >> operation_3