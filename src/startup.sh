#!/bin/sh

cd ~
mkdir .aws

PATH_TO_AWS_CREDS=~/.aws/credentials
PATH_TO_AWS_CONF=~/.aws/config

# check if config exists. otherwise create
[ ! -f $PATH_TO_AWS_CREDS ] && echo "[+] Creating aws config" && \
cat >$PATH_TO_AWS_CONF <<EOL
[default]
region=$S3_REGION
output=text
EOL

# check if credentials exists. otherwise create
[ ! -f $PATH_TO_AWS_CREDS ] && echo "[+] Creating aws credentials" && \
cat >$PATH_TO_AWS_CREDS <<EOL
[default]
aws_access_key_id=$AWS_ACCESS_KEY
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOL

PATH_TO_PG_DUMP_CREDS=~/.pgpass
[ ! -f $PATH_TO_PG_DUMP_CREDS ] && echo "[+] Creating pg_dump credentials" && \
echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" > $PATH_TO_PG_DUMP_CREDS && \
chmod 0600 $PATH_TO_PG_DUMP_CREDS
