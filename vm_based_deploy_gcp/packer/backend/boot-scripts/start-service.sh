#!/bin/bash

mkdir -p /app
service_zip_path=$(find /temp -regex ".*${SERVICE_NAME}.*")
unzip -o $service_zip_path -d /app > /dev/null 2>&1

cd /app
dotnet $SERVICE_DLL