# GitHub Action to Sync S3 Bucket 🔄

> **⚠️ Note:** To use this action, you must have access to the [GitHub Actions](https://github.com/features/actions) feature. GitHub Actions are currently only available in public beta. You can [apply for the GitHub Actions beta here](https://github.com/features/actions/signup/).

This simple action uses the [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.


## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

As of v0.3.0, all [`aws s3 sync` flags](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) are optional to allow for maximum customizability (that's a word, I promise) and must be provided by you via `args:`. The optimal defaults for a static website are set in this example: `--acl public-read` makes your files publicly readable, `--follow-symlinks` won't hurt and fixes some weird symbolic link problems that may come up, and most importantly, `--delete` **permanently deletes** files in the S3 bucket that are **not** present in the latest version of your repository/build.

```yaml
name: Sync Bucket
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: jakejarvis/s3-sync-action@master
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        SOURCE_DIR: './public'
        AWS_REGION: 'us-east-1'
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```


### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository.

| Key | Value | Suggested Type | Required | Default |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret` | **Yes** | N/A |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret` | **Yes** | N/A |
| `AWS_S3_BUCKET` | The name of the bucket you're syncing to. For example, `jarv.is`. | `secret` | **Yes** | N/A |
| `AWS_S3_ENDPOINT` | The endpoint URL of the bucket you're syncing to. Can be used for VPC scenarios or for S3 compliant products like [DigitalOcean Spaces](https://www.digitalocean.com/community/tools/adapting-an-existing-aws-s3-application-to-digitalocean-spaces). | `env` | No | AWS |
| `AWS_REGION` | The region where you created your bucket in. For example, `us-east-1`. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | **Yes** | N/A |
| `SOURCE_DIR` | The local directory you wish to sync/upload to S3. For example, `./public` | `env` | No | `.` |
| `DEST_DIR` | The directory inside of the S3 bucket you wish to sync/upload to. Eg: `my_project/assets`.  | `env` | No | `/` |


## License

This project is distributed under the [MIT license](LICENSE.md).
