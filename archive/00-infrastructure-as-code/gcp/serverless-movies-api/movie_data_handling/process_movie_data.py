"""
This script uploads data from a local JSON file to a Firestore database.

1. It initializes the Firebase Admin SDK using application default credentials.
2. Reads data from a JSON file ('data.json') which contains movie data in a list format.
3. Iterates through the list of movies and uploads each entry to the 'movies' collection in Firestore.
   - Each document is identified by the 'id' field from the JSON data.

Requirements:
- Firebase Admin SDK should be installed and configured.
- The 'data.json' file must exist and be structured as a list of dictionaries.
"""

# Import necessary Firebase Admin SDK and other libraries
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json

# Initialize Firebase Admin SDK with application default credentials
cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)

# Create a Firestore client to interact with the Firestore database
db = firestore.client()

# Open the JSON file containing data
with open('./data.json', 'r') as f:
    # Load the JSON data into a Python list
    data = json.load(f)
    
    # Iterate over each row in the list
    for row in data:
        # Upload each row to the 'movies' collection in Firestore
        # Use the 'id' field in the JSON data as the document ID
        db.collection('movies').document(row['id']).set(row)