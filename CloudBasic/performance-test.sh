#!/bin/bash

# Display help/usage
function show_help {
    echo "Usage: $0 <minio-endpoint> [file-size-in-MB]"
    echo "Example:"
    echo "  $0 ./performance-test.sh https://easyminiostorage.corp.company.it:9000 100"
    echo "  $0 ./performance-test.sh https://localhost:9000 200"
    echo "Arguments:"
    echo "  minio-endpoint   The endpoint URL for the MinIO server"
    echo "  file-size-in-MB  (Optional) Size of the test file to create and upload in megabytes. Defaults to 10MB."
}

# Check for help command or if no MinIO endpoint is provided
if [[ "$1" == "--help" ]] || [ "$#" -lt 1 ]; then
    show_help
    exit 1
fi

# Configuration
MINIO_ENDPOINT="$1"  # Use the first script argument as the MinIO endpoint
FILE_SIZE_MB="${2:-10}"  # Use the second script argument as the file size, default to 10MB if not provided
MINIO_ALIAS="myminio"
ACCESS_KEY="minioadmin"
SECRET_KEY="minioadmin"
BUCKET="test-bucket"
FILE="test-file"

# Set alias for MinIO server
mc -insecure alias set ${MINIO_ALIAS} ${MINIO_ENDPOINT} ${ACCESS_KEY} ${SECRET_KEY}

# Check if the bucket exists, if not, create it
if ! mc --insecure ls ${MINIO_ALIAS}/${BUCKET} &>/dev/null; then
    echo "Creating bucket '${BUCKET}'..."
    mc --insecure mb ${MINIO_ALIAS}/${BUCKET}
fi

# Create a test file of specified size
echo "Creating a ${FILE_SIZE_MB}MB test file..."
dd if=/dev/zero of=${FILE} bs=1M count=${FILE_SIZE_MB} status=none

# Upload the file
echo "Uploading the file..."
time mc --insecure cp ${FILE} ${MINIO_ALIAS}/${BUCKET}/

# Download the file
echo "Downloading the file..."
time mc --insecure cp ${MINIO_ALIAS}/${BUCKET}/${FILE} ${FILE}.downloaded

# Cleanup
echo "Cleaning up..."
rm ${FILE} ${FILE}.downloaded
mc --insecure rm ${MINIO_ALIAS}/${BUCKET}/${FILE}

echo "Performance test completed."
