FROM python:3.8-alpine

LABEL "com.github.actions.name"="S3 Copy"
LABEL "com.github.actions.description"="Copy a directory in one S3 Bucket to another"
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

LABEL version="0.0.1"
LABEL repository="https://github.com/amihangg/s3-copy-action"
LABEL homepage="https://amihan.gg/"
LABEL maintainer="Paul Loy <paul@amihan.gg>"

# https://github.com/aws/aws-cli/blob/master/CHANGELOG.rst
ENV AWSCLI_VERSION='1.18.14'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
