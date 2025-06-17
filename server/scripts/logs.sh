#!/bin/sh
if [ -z "$1" ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

docker logs -f "gis-$1"
