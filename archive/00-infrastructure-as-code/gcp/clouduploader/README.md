# CloudUploader CLI

**CloudUploader CLI** is a simple Bash-based tool that allows users to upload files to Google Cloud Storage from the command line. It offers options to handle file overwrites, renaming, and optional encryption using Google Cloud KMS keys.

## Prerequisites

1. **Google Cloud SDK** installed and configured.
   - To install the Google Cloud SDK, visit [this link](https://cloud.google.com/sdk/docs/install).
2. **Authenticate with Google Cloud** using the following commands:
   ```bash
   gcloud auth login
   gcloud config set project <PROJECT_ID>

## Usage

To upload a file to a Google Cloud Storage bucket, use the following command:

```bash
./clouduploader.sh <FILE_PATH> <STORAGE_BUCKET_NAME>
```

### Example
```bash
./clouduploader.sh /path/to/file.txt my-bucket-name

```

## Features
- File Upload: Uploads a file to the specified Google Cloud Storage bucket.
- File Overwrite Handling: If a file with the same name exists in the bucket, you can choose to:
    -  Overwrite the file.
    - Skip the upload.
    - Rename the file before uploading.
- Encryption Support: You can choose to encrypt the file during the upload using a Google Cloud KMS key.
- Upload Progress Display: The tool uses pv to show progress during file upload.


## Dependencies
Google Cloud SDK: To install, follow the official documentation here.
`pv`: A command-line tool to monitor data progress during the upload process. Install it via:
```bash
sudo apt-get install pv  # For Debian/Ubuntu
brew install pv          # For macOS
```