#!/bin/bash

set -e

TAG="$1"

if [ "$TAG" == "" ]; then
  echo "application tag is not provided as first argument"
  exit 1
fi


script_file="$0"
scripts_dir="$(dirname -- "$script_file")"
"$scripts_dir/check-vars.sh" "in .env file or in system" "ERLANG_OTP_APPLICATION" "CONFLUENCE_SUBDOMAIN" "CONFLUENCE_PAGE_ID" "CONFLUENCE_SECRET"

ERLANG_OTP_APPLICATION_DASH="${ERLANG_OTP_APPLICATION//_/-}"
ERLANG_DOC_DIRNAME="$ERLANG_OTP_APPLICATION_DASH-$TAG-doc"
ERLANG_DOC_ARCHIVE="$ERLANG_DOC_DIRNAME.zip"

echo "confluence: cp documentation directory"
cp -R doc "$ERLANG_DOC_DIRNAME"
echo "confluence: creating documentation .zip archive"
zip -r "$ERLANG_DOC_ARCHIVE" "$ERLANG_DOC_DIRNAME"
echo "confluence: uploading documentation to page $CONFLUENCE_PAGE_ID"
curl -D- \
  --fail \
  -H "Authorization: Basic $CONFLUENCE_SECRET" \
  -X PUT \
  -H "X-Atlassian-Token: nocheck" \
  -F "file=@$ERLANG_DOC_ARCHIVE" \
  -F "minorEdit=true" \
  "https://$CONFLUENCE_SUBDOMAIN.atlassian.net/wiki/rest/api/content/$CONFLUENCE_PAGE_ID/child/attachment"
echo "confluence: documentation uploaded!"
rm -rf "$ERLANG_DOC_DIRNAME"
echo "confluence: tmp documentation dir has been removed"
rm -rf "$ERLANG_DOC_ARCHIVE"
echo "confluence: tmp documentation archive has been removed"
