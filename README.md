# MinIO Cloud Storage System

This repository contains the Docker Compose file and necessary scripts to deploy a MinIO object storage system on your local machine. MinIO is a high-performance, S3 compatible object storage system designed for private and public cloud infrastructure.

## Prerequisites

- Docker and Docker Compose installed on your machine
- `mc` (MinIO Client) installed on your machine for administrative tasks

## Deployment

1. Clone this repository to your local machine.
   ```
    git clone https://github.com/trjohnny/cloud-file-storage.git
    cd cloud-file-storage
   ```
2. Run Docker Compose to start the MinIO server.
    - `docker-compose up -d`
   
   This command will start MinIO in detached mode.

3. To check if MinIO is running correctly, visit `http://localhost:9000` in your web browser. You should see the MinIO login page.

4. To log in to the MinIO console, use the default credentials provided in the Docker Compose file:
   - **Username**: minioadmin
   - **Password**: minioadmin


It's highly recommended to change these default credentials after the first login for security reasons.

## Usage

### Using the MinIO Browser

1. After logging in, you can create buckets, upload/download files, and manage your storage through the MinIO browser interface.

### Using the MinIO Client (mc)

1. Configure `mc` with your MinIO server alias:
    - `mc alias set myminio http://localhost:9000 minioadmin minioadmin`

2. Use `mc` to perform various operations like creating a user, setting a bucket policy, etc. Refer to the MinIO Client documentation for detailed commands.

### Scripts

- `create_user.sh`: This script creates a new MinIO user with a random password and a private bucket. To run the script, use:
    ```
    chmod +x create_user.sh
    ./create_user.sh username
    ```


Replace `username` with the desired username for the new user.

## Scaling, security and monitoring in production

For guidelines on deploying this system in a production environment on AWS, please refer to the guidelines provided in the attached PDF document.
