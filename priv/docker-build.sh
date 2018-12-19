#!/usr/bin/env bash

set -e
set -x

script_file="$0"
scripts_dir="$(dirname -- "$script_file")"
"$scripts_dir/check-vars.sh" "in .env file or in system" "ERLANG_OTP_APPLICATION" "DOCKER_ORG"

app="$DOCKER_ORG/$ERLANG_OTP_APPLICATION"
tag="$1"

if [ "$tag" != "" ]; then
  docker build --rm=false -t "$app" .
  docker tag $app "$app:$tag"
else
  branch=$(git rev-parse --abbrev-ref HEAD | cut -f2 -d"/")
  branch=${branch:-master}
  docker build --rm=false -t "$app:$branch" .
fi
