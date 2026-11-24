# Init notebook
from google.auth.transport.requests import Request
from google.oauth2.service_account import Credentials
import vertexai
import os

# Set environment variables and initialize Vertex AI when module is imported
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/home/diogo/Repos/github.com/diogoguedes11/lab/vertex-ai/gcp-network-452116-7c78a1eff948.json"
os.environ["VERTEX_PROJECT_ID"] = "gcp-network-452116"
os.environ["VERTEX_REGION"] = "us-central1"

api_key_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if not api_key_path:
     raise ValueError("Key not set.")

credentials = Credentials.from_service_account_file(api_key_path, scopes=['https://www.googleapis.com/auth/cloud-platform'])
PROJECT_ID = os.getenv("VERTEX_PROJECT_ID")
REGION = os.getenv("VERTEX_REGION")

vertexai.init(project=PROJECT_ID, location=REGION, credentials=credentials)

print(f"Vertex AI initialized")
