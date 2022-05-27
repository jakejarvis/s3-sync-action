# GitHub Action to Sync S3 Bucket 🔄

This simple action uses the [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.


## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

As of v0.3.0, all [`aws s3 sync` flags](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) are optional to allow for maximum customizability (that's a word, I promise) and must be provided by you via `args:`.

#### The following example includes optimal defaults for a public static website:

- `--acl public-read` makes your files publicly readable (make sure your [bucket settings are also set to public](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html)).
- `--follow-symlinks` won't hurt and fixes some weird symbolic link problems that may come up.
- Most importantly, `--delete` **permanently deletes** files in the S3 bucket that are **not** present in the latest version of your repository/build.
- **Optional tip:** If you're uploading the root of your repository, adding `--exclude '.git/*'` prevents your `.git` folder from syncing, which would expose your source code history if your project is closed-source. (To exclude more than one pattern, you must have one `--exclude` flag per exclusion. The single quotes are also important!)

```yaml
name: Upload Website

on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: jakejarvis/s3-sync-action@master
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: 'us-west-1'   # optional: defaults to us-east-1
        SOURCE_DIR: 'public'      # optional: defaults to entire repository
        AWS_S3_SSE_KMS_KEY_ID: ${{ secrets.AWS_S3_SSE_KMS_KEY_ID }} # optional: defaults to None
```


### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be [set as encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key | Value | Suggested Type | Required | Default |
| --- | ----- | -------------- |--------- | ------- |
| `AWS_ACCESS_KEY_ID` | [AWS Access Key](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `${{ secrets.AWS_ACCESS_KEY_ID }}` | **Yes** | N/A |
| `AWS_SECRET_ACCESS_KEY` | [AWS Secret Access Key](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `${{ secrets.AWS_SECRET_ACCESS_KEY }}` | **Yes** | N/A |
| `AWS_S3_BUCKET` | bucket-name | `secret env` | **Yes** | N/A |
| `AWS_REGION` | [bucket region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | No | `us-east-1` |
| `AWS_S3_ENDPOINT` | sync endpoint | `env` | No | Automatic (`s3.amazonaws.com` or AWS's region-specific equivalent) |
| `AWS_DOWNSTREAM` | synchronize downstream with your local directory | `env` | No | `us-east-1` |
| `AWS_ASSUME_ROLE_ARN` | role ARN. | `env` | No | N/A |
| `SOURCE_DIR` | The local directory (or file) you wish to sync with S3. For example, `public` | `env` | No | `./` (root of cloned repository) |
| `DEST_DIR` | The directory inside of the S3 bucket you wish to sync with. For example, `my_project/assets` | `env` | No | `/` (root of bucket) |
| `AWS_S3_SSE_KMS_KEY_ID` | [SSE-KMS id](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html) | `${{ secrets.AWS_S3_SSE_KMS_KEY_ID }}` | No | N/A |


### AWS ROLE config

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "s3actionsync",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::YOUR_BUCKET_NAME",
                "arn:aws:s3:::YOUR_BUCKET_NAME/*"
            ]
        }
    ]
```

## License

This project is distributed under the [MIT license](LICENSE.md).
