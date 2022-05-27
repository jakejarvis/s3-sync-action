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

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Use the AWS directory as source to sync downstream.
# Default to false if AWS_DOWNSTREAM not set.
if [ "$AWS_DOWNSTREAM" = true ]; then
  SOURCE_PATH="s3://${AWS_S3_BUCKET}/${DEST_DIR}" # AWS S3 directory as source
  DEST_PATH="${SOURCE_DIR:-.}"                    # Local directory as destination
else
  SOURCE_PATH="${SOURCE_DIR:-.}"                # Local directory as source
  DEST_PATH="s3://${AWS_S3_BUCKET}/${DEST_DIR}" # AWS S3 directory as destination
fi

AWS_PROFILE=s3-sync-action

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile ${AWS_PROFILE} <<- EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

if [ -n "$AWS_ASSUME_ROLE_ARN" ]; then
  echo "Assuming role: ${AWS_ASSUME_ROLE_ARN}"

  # Create a profile to assume the role with.
  # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html
  {
    echo "[profile s3-sync-action-assume]"
    "role_arn = ${AWS_ASSUME_ROLE_ARN}"
    "source_profile = ${AWS_PROFILE}"
  } >> ~/.aws/config

  AWS_PROFILE=s3-sync-action-assume
fi

# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
CMD_PREFIX="aws s3 sync"
if [ -n "$AWS_S3_SSE_KMS_KEY_ID" ]; then
  CMD_PREFIX="${CMD_PREFIX} --sse aws:kms --sse-kms-key-id ${AWS_S3_SSE_KMS_KEY_ID}"
fi

sh -c "${CMD_PREFIX} ${SOURCE_PATH} ${DEST_PATH} \
  --profile ${AWS_PROFILE} \
  --no-progress \
  ${ENDPOINT_APPEND} $*"

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-sync-action <<- EOF > /dev/null 2>&1
null
null
null
text
EOF
