#!/usr/bin/env sh
# Generate the PHP client from the compiled OpenAPI spec.
#
# See scripts/generate-go.sh for notes on how this script is invoked from
# CI vs the local Makefile.
set -eu

SPEC=${SPEC:-api/openapi-spec/v1.0.yaml}
OUTPUT_DIR=${OUTPUT_DIR:-libre-graph-api-php}
TEMPLATES=${TEMPLATES:-templates/php-nextgen}

/usr/local/bin/docker-entrypoint.sh generate \
  --enable-post-process-file \
  -i "$SPEC" \
  --additional-properties=packageName=libregraph \
  --git-user-id=opencloud-eu \
  --git-repo-id=libre-graph-api-php \
  -g php-nextgen \
  -t "$TEMPLATES" \
  -o "$OUTPUT_DIR"
