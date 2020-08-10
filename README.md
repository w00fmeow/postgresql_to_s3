# postgresql_to_s3
PostgreSQL automatic backups to Amazon S3 bucket in Docker.

## Overview
Automatically backup PostgreSQL database and upload it directly to Amazon S3 bucket.

#### Features:
 * Rotation logic
 * GPG encryption with provided passphrase
 * Notifications to Telegram

 __Keep in mind!! No local backup files are kept__

## Setup

1. Built container and push to your registry
`docker build /path_to_source && docker push <host/name:tag>`
2. Deploy on Kubernetes. A couple of variables are needed for deployment.

Required environment variables:
```
POSTGRES_BACKUP_PASSPHRASE = Passphrase to use for encryption
POSTGRES_USER = Username in PostgreSQL
POSTGRES_PASSWORD = PostgreSQL password
POSTGRES_DB = Name of the database
POSTGRES_HOST = Host name or ip address of PostgreSQL instance
POSTGRES_PORT = PostgreSQL port
S3_BUCKET = Name of S3 bucket
S3_REGION = S3 region
AWS_ACCESS_KEY = AWS Access key
AWS_SECRET_ACCESS_KEY = AWS secret access key
TELEGRAM_TOKEN = Bot token
TELEGRAM_CHAT_ID = Chat id
KEEP_BACKUPS_IN_DAYS = Format: Integer. For automatic deletion of old backups
```

Demo yaml is provided: _demo-k8s-deployment.yaml_

Feel free to edit the scripts to fit your needs
