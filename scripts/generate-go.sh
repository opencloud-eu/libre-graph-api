#!/usr/bin/env sh
# Generate the Go client from the compiled OpenAPI spec.
#
# Designed to run inside the openapitools/openapi-generator-cli container —
# that's the CI mode. Locally the Makefile wraps the script in `docker run`
# against the same image (pulled from .woodpecker/build-go.yaml).
set -eu

SPEC=${SPEC:-api/openapi-spec/v1.0.yaml}
OUTPUT_DIR=${OUTPUT_DIR:-libre-graph-api-go}

/usr/local/bin/docker-entrypoint.sh generate \
  --enable-post-process-file \
  -i "$SPEC" \
  --additional-properties=packageName=libregraph \
  --git-user-id=opencloud-eu \
  --git-repo-id=libre-graph-api-go \
  -g go \
  -o "$OUTPUT_DIR" \
  --api-name-suffix Api
