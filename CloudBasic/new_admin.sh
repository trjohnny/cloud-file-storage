#!/bin/sh

# Function to show help message
show_help() {
    echo "Usage: $0 <minio-endpoint> <username>"
    echo "Example:"
    echo "  $0 http://localhost:9000 foo_admin"
    echo "  $0 https://easyminiostorage.corp.company.it:9000 bar_admin"
    echo "Options:"
    echo "  --help          Display this help message and exit"
    echo "Creates a new admin user in MinIO with a random password and assigns policies to manage users and buckets."
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

# Create the admin user with the generated password
mc admin user add myminio "$USERNAME" "$PASSWORD"

# Create a policy file for the admin user
ADMIN_POLICY_NAME="${USERNAME}AdminPolicy"
ADMIN_POLICY_JSON="/tmp/${ADMIN_POLICY_NAME}.json"

cat <<EOT > "$ADMIN_POLICY_JSON"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "admin:*",
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Sid": ""
        }
    ]
}
EOT

# Add the policy to MinIO
mc admin policy create myminio "$ADMIN_POLICY_NAME" "$ADMIN_POLICY_JSON"

# Link the policy to the user
mc admin policy attach myminio "$ADMIN_POLICY_NAME" --user "$USERNAME"

# Clean up the policy JSON file
rm "$ADMIN_POLICY_JSON"

# Output the generated password
echo "Admin user created successfully!"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
