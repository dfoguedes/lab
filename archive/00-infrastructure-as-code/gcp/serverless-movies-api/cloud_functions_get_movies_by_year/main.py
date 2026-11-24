import functions_framework
import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase Admin SDK once (outside the function)
cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)

# Create Firestore client (also outside the function to reuse)
db = firestore.client()

@functions_framework.http
def get_movies_by_year(request):
    try:
        # Extract the release_year from the URL path
        release_year = request.path.strip("/")

        # Ensure release_year is a string to match the Firestore data type
        if not release_year:
            return json.dumps({"error": "release_year in URL path is required"}), 400, {"Content-Type": "application/json"}

        # Query Firestore for movies with the given release year
        movies = db.collection("movies").where("release_year", "==", release_year).stream()

        # Store movie data in a list
        list_movies = [movie.to_dict() for movie in movies]

        # Return the list of movies as a JSON response
        return json.dumps(list_movies), 200, {"Content-Type": "application/json"}
    except Exception as e:
        print(f"Error occurred: {e}")
        return (
            json.dumps({"error": "Failed to fetch movies"}),
            500,
            {"Content-Type": "application/json"},
        )