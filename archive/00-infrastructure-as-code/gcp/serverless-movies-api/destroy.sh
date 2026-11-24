#!/bin/bash

# This script will be a one-shot script designed to fully destroy the entire environment.

# Prerequisites
# Authentication with: `gcloud auth application-default login`

# Ensure script exits on any command failure
set -e 

# List of Cloud Functions to delete
FUNCTIONS=("get_movies" "get_movies_by_year")

destroy_cloudfunctions() {
    for func_name in "${FUNCTIONS[@]}"; do
        echo "[*] Deleting Cloud Function ${func_name}..."
        if ! gcloud functions delete "${func_name}" --quiet; then
            echo "[-] Something went wrong; the Cloud Function ${func_name} may not exist."
            exit 1
        fi
        echo "[*] Deleted function ${func_name} successfully."
    done
}  # Closing brace for destroy_cloudfunctions

main() {
    destroy_cloudfunctions
}

main
