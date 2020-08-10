#!/bin/sh

# create credentials
/src/startup.sh

echo "[+] Backup of database $POSTGRES_DB is starting"

PATH_TO_RAW_BACKUP_FILE=/tmp/pg_backup.dump

# check for old backups
[ -f $PATH_TO_RAW_BACKUP_FILE ] && rm $PATH_TO_RAW_BACKUP_FILE

# execute backup
pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB > $PATH_TO_RAW_BACKUP_FILE

# gzip pg_dump
[ -f $PATH_TO_RAW_BACKUP_FILE ] && gzip $PATH_TO_RAW_BACKUP_FILE || exit

# Encrypt the gzipped backup file
# using GPG passphrase
gpg --yes --batch --passphrase=$PG_BACKUP_PASSWORD -c $PATH_TO_RAW_BACKUP_FILE.gz

# Generate backup filename based
# on the current date
BACKUP_FILE_NAME="$POSTGRES_HOST-$(date '+%Y-%m-%d_%H.%M').gpg"

# Upload the file to S3 using
# AWS CLI
aws s3 cp $PATH_TO_RAW_BACKUP_FILE.gz "s3://$S3_BUCKET/${BACKUP_FILE_NAME}" && \
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_1 -d text="Successfull $POSTGRES_DB backup" || \
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_1 -d text="Backup failed for $POSTGRES_DB"

# Remove the encrypted + plaintext backup file
rm $PATH_TO_RAW_BACKUP_FILE.gz.gpg
rm $PATH_TO_RAW_BACKUP_FILE.gz

# delete file from s3 bucket
delete_from_s3 () {
  echo "Deleting old backup - $1"
  aws s3 rm s3://$S3_BUCKET/$1
}

today=$(date '+%Y-%m-%d')
keep_days=$KEEP_BACKUPS_IN_DAYS
pattern=".*$POSTGRES_HOST-.*$"
pat_date='[0-9]{4}-[0-9]{2}-[0-9]{2}'

# load all backup files on aws
all_files=$(aws s3 ls s3://$S3_BUCKET | grep $pattern | awk '{print $4}')

for file in $all_files
do
  file_date=$(echo $file | grep -E -o $pat_date)
  diff_float=$(echo "( `date -d $today +%s` - `date -d $file_date +%s`) / (24*3600)" | bc -l)
  diff_int=${diff_float%.*}
  if [ $diff_int -gt $keep_days ]; then
    # delete old backup object from aws
    delete_from_s3 $file
  fi
done
