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
    - `mc alias set myminio <endpoint> minioadmin minioadmin`
      
   Replace `<endpoint>` with the correct URL (e.g. http://localhost:9000)

2. Use `mc` to perform various operations like creating a user, setting a bucket policy, etc. Refer to the MinIO Client documentation for detailed commands.

### Scripts

- `new_user.sh`: This script creates a new MinIO user with a random password and a private bucket. To run the script, use:
    ```
    chmod +x new_user.sh
    ./new_user.sh <endpoint> <username>
    ```

- `new_admin_.sh`: This script creates a new MinIO admin with a random password and a private bucket. To run the script, use:
    ```
    chmod +x new_admin.sh
    ./new_admin.sh <endpoint> <username>
    ```


Replace `<username>` with the desired username for the new user and `<endpoint>` with the correct URL.

## Scaling, security and monitoring in production

For guidelines on deploying this system in a production environment on AWS, please refer to the guidelines provided in the attached PDF document.

## Use HTTPS

To use certgen, follow these steps:

1. Execute the certgen go script to generate a private key and a public certificate:
   ```
   go run certgen --host="easyminiostorage.corp.company.it"
   ```
   Replace the host with the desired domain. The command will create two files: private.key and public.crt.

   (Advanced) If you want to use custom-CA signed certificates, navigate into the `./company-CA` folder and use the private.key and public.crt file inside.

2. Place these files in the MinIO server's configuration directory under `~/.minio/certs/`. For Docker deployments, this would typically involve mounting the directory containing the certificates to the container (folder `./certs`).

3. Configure MinIO to use HTTPS by setting the `MINIO_SERVER_URL` environment variable to the desired URL (e.g. https://easyminiostorage.corp.company.it).

4. Update the Docker Compose file to reflect the TLS configuration:

   ```
   services:
      minio:
         ...
         environment:
            MINIO_SERVER_URL: "https://easyminiostorage.corp.company.it"
         ...
   ```

5. Restart the MinIO service to apply the changes. (Advanced) If using CA-signed certificates, install the `company-CA.crt` certificate placing it into the system keychain.

You can find at the following link the complete documentation on the usage of MinIO over HTTPS: https://min.io/docs/minio/linux/operations/network-encryption.html