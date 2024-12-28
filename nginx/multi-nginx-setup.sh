#!/usr/bin/env bash

set -ueo pipefail


Base=~/temp/html

SiteHTML=" <html>
    <title>Welcome to ${s%.*/}</title>
    <h1> This is ${s%*./}<h1>
    </html>"

sites=( "$Base/sx1" "$Base/sx2" "$Base/sx3")

for s in "${sites[@]}"
do
    mkdir -p -- "$s"
    echo "$SiteHTML" > "$s"/index.html
    chown -R -- "$(id -u):$(id -g)" "$s"

done





