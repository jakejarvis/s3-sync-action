# GitHub Action to Sync S3 Bucket 🔄 

> **⚠️ Note:** To use this action, you must have access to the [GitHub Actions](https://github.com/features/actions) feature. GitHub Actions are currently only available in public beta. You can [apply for the GitHub Actions beta here](https://github.com/features/actions/signup/).

This simple action uses the [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.

**Performing this action deletes any files in the bucket that are *not* present in the source directory.** Working on making this optional in the next release!

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

```
name: Sync Bucket
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: jakejarvis/s3-sync-action@master
      env:
        SOURCE_DIR: './public'
        AWS_REGION: 'us-east-1'
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```


### Required Environment Variables

| Key | Value | Type | Required |
| ------------- | ------------- | ------------- | ------------- |
| `SOURCE_DIR` | The local directory you wish to sync/upload to S3. For example, `./public`. | `env` | **Yes** |
| `AWS_REGION` | The region where you created your bucket in. For example, `us-east-1`. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | **Yes** |


### Required Secret Variables

The following variables should be added as "secrets" in the action's configuration.

| Key | Value | Type | Required |
| ------------- | ------------- | ------------- | ------------- |
| `AWS_S3_BUCKET` | The name of the bucket you're syncing to. For example, `jarv.is`. | `secret` | **Yes** |
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret` | **Yes** |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret` | **Yes** |


## License

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](https://creativecommons.org/publicdomain/zero/1.0/)

To the extent possible under law, [Jake Jarvis](https://jarv.is/) has waived all copyright and related or neighboring rights to this work.
