#!/bin/bash

mkdir -p /temp

build_suffix=$1

services=("gateway" "offers" "identity" "carts" "orders" "notification")

for service in ${services[@]} ; do
        build_filename="${service}_${build_suffix}.zip"
        gsutil cp "gs://eszop-app-storage/${build_filename}" /temp
done