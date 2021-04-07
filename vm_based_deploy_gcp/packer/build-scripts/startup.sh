#!/bin/bash

keys=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/" -H "Metadata-Flavor: Google")
for key in ${keys[@]}; do
        val=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${key}" -H "Metadata-Flavor: Google")
        printf -v $key "${val}" > /dev/null 2>&1
done

if [ -z "$SERVICE_NAME" ]
then
        echo "SERVICE_NAME is not set" 1>&2
        return -1
fi

if [ -z "$SERVICE_ENTRYPOINT" ] ; then
        echo "SERVICE_ENTRYPOINT is not set" 1>&2
        return -1
fi