#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$component = Get-Content -Path "component.json" | ConvertFrom-Json
$image="$($component.registry)/$($component.name):$($component.version)-lambda-build"
$container="$($component.name)-lambda"

# Remove build files
if (Test-Path "obj") {
    Remove-Item -Recurse -Force -Path "obj"
}

# Build docker image
docker build -f docker/Dockerfile_lambda.build -t $image .

# Create and copy compiled files, then destroy
docker create --name $container $image
docker cp "$($container):/app/lambda.zip" ./bin/lambda.zip
docker cp "$($container):/app/lambda_cmd.zip" ./bin/lambda_cmd.zip
docker rm $container
