#!/bin/sh

set -e

mkdir ~/.aws
touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials

aws s3 sync ${SOURCE_DIR} s3://${AWS_S3_BUCKET} \
            --follow-symlinks \
            --delete \
            --region ${AWS_REGION} \
            --metadata-directive "REPLACE"
