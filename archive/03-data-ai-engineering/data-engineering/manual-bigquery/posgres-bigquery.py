from sqlalchemy import create_engine
import pandas as pd
from google.cloud import bigquery

engine = create_engine("postgresql://teste:teste123@localhost:5432/testdb")

df = pd.read_sql("SELECT * FROM Persons;", engine)

print(df["lastname"])


client = bigquery.Client()
dataset_id = "test_dataset"

df.to_gbq(f"{dataset_id}.Persons",
          project_id=client.project, if_exists="replace")


print(f"Dataframe uploaded to {dataset_id}.Persons in BigQuery.")
