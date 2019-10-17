#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is not set. Quitting."
  exit 1
fi

# Default to syncing entire repo if SOURCE_DIR not set.
SOURCE_DIR=${SOURCE_DIR:-.}
ENDPOINT_APPEND=${"--endpoint-url $AWS_S3_ENDPOINT":-}

# Create a dedicated profile for this action to avoid
# conflicts with other actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Use our dedicated profile and suppress verbose messages.
# All other flags are optional via `args:` directive.
sh -c "aws s3 sync ${SOURCE_DIR} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile s3-sync-action \
              ${ENDPOINT_APPEND} \
              --no-progress $*"
