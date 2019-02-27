## requirements

- [ ] [docker](https://www.docker.com/get-started)
- [ ] export aws programmatic access:

```sh
# AWS
export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=bar
```

## installation

```sh
docker build -f ./.docker/Dockerfile -t aws-lambda-php .

docker run \
    --rm \
    -v ${PWD}:/opt/aws-lambda-php \
    -w /opt/aws-lambda-php \
    aws-lambda-php \
    cp -f /home/ec2-user/php-7-bin/bin/php ./runtime/bin

docker run \
    --rm \
    -v ${PWD}:/opt/aws-lambda-php \
    -w /opt/aws-lambda-php \
    aws-lambda-php \
    cp -rf /home/ec2-user/php-7-bin/lib/php/extensions/no-debug-non-zts-20180731/. ./runtime/lib/php/extensions/

docker run \
    --rm \
    -v ${PWD}:/opt/aws-lambda-php \
    -w /opt/aws-lambda-php \
    aws-lambda-php \
    /home/ec2-user/php-7-bin/bin/php /usr/local/bin/composer install --no-dev --no-interaction --no-suggest --optimize-autoloader --prefer-dist
```

## deploy

```sh
docker run \
    --rm \
    -v ${PWD}:/opt/aws-lambda-php \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -w /opt/aws-lambda-php/.terraform \
    hashicorp/terraform:0.11.11 \
    init

docker run \
    --rm \
    -i \
    -v ${PWD}:/opt/aws-lambda-php \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -w /opt/aws-lambda-php/.terraform \
    hashicorp/terraform:0.11.11 \
    apply
```

## destroy

```sh
docker run \
    --rm \
    -i \
    -v ${PWD}:/opt/aws-lambda-php \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -w /opt/aws-lambda-php/.terraform \
    hashicorp/terraform:0.11.11 \
    destroy
```
