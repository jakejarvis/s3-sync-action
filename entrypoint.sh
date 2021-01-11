#!/bin/sh

apt-get install jq

SaveCredentials() {
  [[ -d ~/.assumerole.d/cache ]] || mkdir -p ~/.assumerole.d/cache

  echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > ~/.assumerole.d/cache/${aws_account}
  echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export ROLE=${ROLE}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export ACCOUNT=${ACCOUNT}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export AWS_ACCOUNT_ID=${ACCOUNT}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export aws_account=${aws_account}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export AWS_ACCOUNT=${aws_account}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export AWS_EXPIRATION=${AWS_EXPIRATION}" >> ~/.assumerole.d/cache/${aws_account}
  echo "export SSHKEY=${SSHKEY}" >> ~/.assumerole.d/cache/${aws_account}
  echo ${ASSUMEROLE_ENV} >> ~/.assumerole.d/cache/${aws_account}

  chmod 0600 ~/.assumerole.d/cache/${aws_account}
}

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

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Assume Role if user sets AWS_ASSUMED_ROLE.
if [ -n "$AWS_ASSUMED_ROLE" ]; then
  role_arn="$AWS_ASSUMED_ROLE"
  
  export AWS_PROFILE=${PROFILE}
  
  JSON=$(aws sts assume-role \
          --role-arn "$AWS_ASSUMED_ROLE" \
          --role-session-name "S3 Update CI" \
          --duration-seconds 600
          2>/dev/null) || { echo "Error assuming role"; exit 1; }
  
  AWS_ACCESS_KEY_ID=$(echo ${JSON} | jq --raw-output ".Credentials[\"AccessKeyId\"]")
  AWS_SECRET_ACCESS_KEY=$(echo ${JSON} | jq --raw-output ".Credentials[\"SecretAccessKey\"]")
  AWS_SESSION_TOKEN=$(echo ${JSON} | jq --raw-output ".Credentials[\"SessionToken\"]")
  AWS_EXPIRATION=$(echo ${JSON} | jq --raw-output ".Credentials[\"Expiration\"]")
  
  unset AWS_PROFILE
  
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
  export AWS_ACCOUNT=${aws_account}
  export AWS_ACCOUNT_ID=${ACCOUNT}
  
  # SaveCredentials
fi

# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
