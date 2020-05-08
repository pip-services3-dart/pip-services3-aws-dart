#!/bin/sh

echo 'Starting compile Lambda functions'
# setting cache folder
export PUB_CACHE=/tmp

# creating a temporary directory for the build
cd $(mktemp -d)

# pub the app
cp -Rp /app/* .
ls -l
# setup deps
echo 'setup deps'
/usr/lib/dart/bin/pub get
# build the binary
echo 'build the binary'
/usr/lib/dart/bin/dart2native bin/main_lambda.dart -o bootstrap
# move this back to app
echo 'move this back to app'
mv bootstrap /app/bootstrap
zip lambda.zip bootstrap 
rm bootstrap

# build the binary for commandable
echo 'build the binary for commandable'
/usr/lib/dart/bin/dart2native bin/main_lambda_cmd.dart -o bootstrap
# move this back to app
echo 'move this back to app'
mv bootstrap /app/bootstrap
zip lambda_cmd.zip bootstrap 
rm bootstrap