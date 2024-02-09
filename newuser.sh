#!/bin/sh

# Check for username argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Assign username from the first argument
USERNAME=$1

# Generate a random password
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# Set the alias for the MinIO server (adjust endpoint and access keys as needed)
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create the user with the generated password
mc admin user add myminio "$USERNAME" "$PASSWORD"

# Create a bucket for the user
mc mb myminio/"${USERNAME}-bucket"

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
mc admin policy add myminio "$POLICY_NAME" "$POLICY_JSON"

# Link the policy to the user
mc admin policy set myminio "$POLICY_NAME" user="$USERNAME"

# Clean up the policy JSON file
rm "$POLICY_JSON"

# Output the generated password
echo "User created successfully!"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"

