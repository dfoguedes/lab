# This script will be a one-shot script designed to fully replicate the entire environment.

# Prerequisites
# Authentication with: `gcloud auth application-default login`


# Ensure script exits on any command failure
set -e 

# Parameters
RUNTIME="python310"
REGION="us-central1"

check_gcloud_auth() {
  echo "[*] Check gcloud authentication..."
  gcloud auth application-default print-access-token > /dev/null 2>&1
  if [ $? -ne 0 ]; then
      echo "Error: Not authenticated with gcloud. Run 'gcloud auth application-default login' to authenticate."
      exit 1
  else 
    echo "[*] gcloud is authenticated."
  fi

}
# Add data to the (default) firestore database
handle_data() {
  echo "[*] Processing movie data..."
  if [ ! -d "movie_data_handling" ]; then
    echo "Error: Directory 'movie_data_handling' does not exist."
    exit 1
  fi
  cd movie_data_handling
  if  ! python3 process_movie_data.py ; then
    echo "Error: Failed to process movie data. Ensure Python is installed and the script is correct."
    exit 1
  fi
    echo "[*] Movie data processed successfully."
}

deploy_cloud_functions_get_movies() {
    echo "[*] Deploying Cloud Function Get Movies"
    cd ..
    if [ ! -d 'cloud_functions_get_movies' ]; then
      echo "Error: Directory 'cloud_functions_get_movies' does not exist"
      exit 1
    fi
    cd cloud_functions_get_movies;
    if  ! gcloud functions deploy get_movies \
    --runtime $RUNTIME \
    --trigger-http \
    --allow-unauthenticated \
    --entry-point get_movies \
    --region $REGION \
    --gen2; then
    echo "Error: Failed to deploy get movies Cloud function. Ensure Python is installed and the script is correct."
    exit 1
    fi
    echo "[*] Get Movies Cloud Function deployed successfully."
}
deploy_cloud_functions_get_movies_by_year() {
    echo "[*] Deploying Cloud Function Get Movies By Year"
    cd ..
    if [ ! -d 'cloud_functions_get_movies' ]; then
      echo "Error: Directory 'cloud_functions_get_movies_by_year' does not exist"
      exit 1
    fi
    cd cloud_functions_get_movies_by_year;
    if  ! gcloud functions deploy get_movies_by_year \
    --runtime $RUNTIME \
    --trigger-http \
    --allow-unauthenticated \
    --entry-point get_movies_by_year \
    --region $REGION \
    --gen2; then
    echo "Error: Failed to deploy get movies Cloud function. Ensure Python is installed and the script is correct."
    exit 1
    fi
    echo "[*] Get Movies By Year Cloud Function deployed successfully."
}

main() {
 check_gcloud_auth
 handle_data
 deploy_cloud_functions_get_movies
 #deploy_cloud_functions_get_movies_by_year
}


main