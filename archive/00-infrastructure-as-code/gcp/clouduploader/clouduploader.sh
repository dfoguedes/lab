#!/bin/bash
set -e

# This script is a CLI tool that uploads files to Google Cloud Storage with optional encryption.
# Usage: ./clouduploader.sh <FILE_PATH> <STORAGE_BUCKET_NAME>

echo "Welcome to the Google Cloud Storage Uploader CLI"

# Prerequisites: Authenticate with Google Cloud
# gcloud auth login
# gcloud config set project <PROJECT_ID>

FILE_PATH="$1"
STORAGE_BUCKET_NAME="$2"
re='^[0-9]+$'

# Function to validate input parameters
validate_input() {
    # Ensure correct number of arguments is passed
    if [[ $# -ne 2 ]]; then
        echo "Error: Please provide both a file path and a storage bucket name."
        echo "Usage: ./clouduploader.sh <FILE_PATH> <STORAGE_BUCKET_NAME>"
        exit 1
    fi
    # Validate that FILE_PATH is not a number
    if [[ $FILE_PATH =~ $re ]]; then
        echo "Error: The file path cannot be a number. Please provide a valid file path." >&2
        exit 1
    fi
    # Validate that STORAGE_BUCKET_NAME is not a number
    if [[ $STORAGE_BUCKET_NAME =~ $re ]]; then
        echo "Error: The bucket name cannot be a number. Please provide a valid bucket name." >&2
        exit 1
    fi
}

# Function to handle file upload success or failure
handle_upload_result() {
    if [[ $? -eq 0 ]]; then
        echo "Success: The file '$(basename "$FILE_PATH")' has been uploaded to the Google Cloud Storage bucket '$STORAGE_BUCKET_NAME'."
        echo "Share Link: https://storage.cloud.google.com/$STORAGE_BUCKET_NAME/$(basename "$FILE_PATH")"
    else
        echo "Error: The file upload failed. Please check your internet connection, bucket permissions, and try again."
    fi
}

# Function to process file upload with or without encryption
upload_file() {
    local encryption_option=$1
    if [[ $encryption_option == "no" ]]; then
        pv "$FILE_PATH" | gcloud storage cp - gs://"$STORAGE_BUCKET_NAME"/"$(basename "$FILE_PATH")"
    elif [[ $encryption_option == "yes" ]]; then
        echo "Enter your KMS key resource:"
        read -r kms_key
        if [[ -z $kms_key ]]; then
            echo "Error: KMS key cannot be empty."
            exit 1
        fi
        pv "$FILE_PATH" | gcloud storage cp - gs://"$STORAGE_BUCKET_NAME"/"$(basename "$FILE_PATH")" --encryption-key="$kms_key"
    else
        echo "Error: Invalid choice. Please answer 'yes' or 'no'."
        exit 1
    fi
}

# Function to check if the file already exists in the bucket and handle the user's choice
handle_existing_file() {
    if gcloud storage ls gs://"$STORAGE_BUCKET_NAME"/"$(basename "$FILE_PATH")" > /dev/null 2>&1; then
        echo "Warning: The file '$(basename "$FILE_PATH")' already exists in the bucket '$STORAGE_BUCKET_NAME'."
        echo "Please choose how to proceed:"
        echo "[1] Overwrite"
        echo "[2] Skip"
        echo "[3] Rename the file"
        read -r user_choice

        case $user_choice in
            1)
                echo "You chose to overwrite the existing file."
                ;;
            2)
                echo "You chose to skip the upload."
                exit 0
                ;;
            3)
                echo "You chose to rename the file."
                echo "Enter the new file name:"
                read -r new_file_name
                mv "$FILE_PATH" "$(dirname "$FILE_PATH")/$new_file_name"
                FILE_PATH="$(dirname "$FILE_PATH")/$new_file_name"
                ;;
            *)
                echo "Invalid option. Exiting."
                exit 1
                ;;
        esac
    fi
}

# Main function to execute the upload logic
main() {
    validate_input "$@"

    # Ensure the file exists locally
    if [[ -f "$FILE_PATH" ]]; then
        handle_existing_file

        # Ask the user if they want to encrypt the file
        echo "Do you want to encrypt your file? (yes or no)"
        read -r encryption_option
        
        # Handle the upload process
        upload_file "$encryption_option"

        # Output the result
        handle_upload_result
    else
        echo "Error: The file '$FILE_PATH' does not exist. Please provide a valid file path."
        exit 1
    fi
}

# Run the main function with script arguments
main "$@"