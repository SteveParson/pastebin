#!/bin/bash
set -euox pipefail

cd lambda-src
rm -rf lambda.zip
docker run -v "${PWD}:/app" -w /app node:14 npx prettier --write snippets.js
docker build -t lambda-packager .
docker run --rm lambda-packager cat /app/lambda.zip > lambda.zip
cd ..
#terraform fmt *.tf
#terraform destroy -auto-approve
#terraform validate
#terraform apply -auto-approve
