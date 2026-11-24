# Serverless Movies API

This project is a capstone demonstrating the use of serverless cloud functions to create an API that interacts with a NoSQL database and cloud storage to display movie information. The API includes endpoints to retrieve all movies or filter them by release year. The project is built using Google Cloud Functions, Firestore (NoSQL), and Cloud Storage.

## Features

- **GetMovies**: Fetches a list of all movies in the database, including their details and a URL for the movie cover image.
- **GetMoviesByYear**: Fetches a list of movies released in a specified year. The year is passed in the URL as part of the request.

## Cloud Infrastructure

This project uses the following Google Cloud services:

- **Firestore (NoSQL database)**: Stores movie information such as title, director, release year, genre, and more.
- **Cloud Storage**: Stores movie cover images and provides a URL for the images.
- **Google Cloud Functions**: Provides serverless functions to handle API requests.

## Prerequisites

To run this project, you will need:

- A Google Cloud account with billing enabled
- Google Cloud SDK installed and authenticated on your local machine
- Firebase Admin SDK configured with the required permissions to access Firestore and Cloud Storage

## Project Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/serverless-movies-api.git
   cd serverless-movies-api