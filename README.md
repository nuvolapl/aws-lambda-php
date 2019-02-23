## requirements

- [ ] [docker](https://www.docker.com/get-started)
- [ ] [terrafom](https://learn.hashicorp.com/terraform/#getting-started)
- [ ] some access keys:

```sh
# AWS
export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=bar

# CLOUDFLARE
export CLOUDFLARE_EMAIL=foo
export CLOUDFLARE_TOKEN=bar
```

## installation

```sh
docker build -f ./.docker/Dockerfile -t aws-lambda-php .

docker run \
    --rm \
    -v ${PWD}/runtime/bin:/home/ec2-user/runtime/bin \
    aws-lambda-php \
    cp -f ./php-7-bin/bin/php ./runtime/bin

docker run \
    --rm \
    -v ${PWD}/runtime:/home/ec2-user/runtime \
    aws-lambda-php \
    cp -rf ./php-7-bin/lib/php/extensions/no-debug-non-zts-20180731/. ./runtime/lib/php/extensions/

docker run \
    --rm \
    -v ${PWD}:/home/ec2-user/project \
    -w /home/ec2-user/project \
    aws-lambda-php \
    /home/ec2-user/php-7-bin/bin/php /usr/local/bin/composer install
```

## deploy
```sh
cd .terraform

terraform init
terraform apply -var 'domain=nuvola.pl'
```
