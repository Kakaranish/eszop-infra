#!/bin/bash

keys=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/" -H "Metadata-Flavor: Google")
for key in ${keys[@]}; do
        val=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${key}" -H "Metadata-Flavor: Google")
        export $key="${val}" > /dev/null 2>&1
done

. /scripts/start-service.sh