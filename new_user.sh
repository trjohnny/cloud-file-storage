#!/bin/sh

# Function to show help message
show_help() {
    echo "Usage: $0 <minio-endpoint> <username>"
    echo "Example:"
    echo "  $0 http://localhost:9000 foo_user"
    echo "  $0 https://easyminiostorage.corp.company.it:9000 bar_user"
    echo "Options:"
    echo "  --help          Display this help message and exit"
    echo "Creates a new user in MinIO with a random password and a bucket with a 10GB quota."
}

# Check for help argument
if [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    show_help
    exit 1
fi

# Assign endpoint and username from the arguments
ENDPOINT=$1
USERNAME=$2

# Generate a random password
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# Set the alias for the MinIO server
mc alias set myminio $ENDPOINT minioadmin minioadmin

# Create the user with the generated password
mc admin user add myminio "$USERNAME" "$PASSWORD"

# Create a bucket for the user
mc mb myminio/"${USERNAME}-bucket"

# Set bucket quota to 5GB
mc quota set --size 5GiB myminio/"${USERNAME}-bucket"

# Create a policy file for the user
POLICY_NAME="${USERNAME}Policy"
POLICY_JSON="/tmp/${POLICY_NAME}.json"

cat <<EOT > "$POLICY_JSON"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${USERNAME}-bucket"
            ],
            "Sid": ""
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${USERNAME}-bucket/*"
            ],
            "Sid": ""
        }
    ]
}
EOT

# Add the policy to MinIO
mc admin policy create myminio "$POLICY_NAME" "$POLICY_JSON"

# Link the policy to the user
mc admin policy attach myminio "$POLICY_NAME" --user "$USERNAME"

# Clean up the policy JSON file
rm "$POLICY_JSON"

# Output the generated password
echo "User created successfully!"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
