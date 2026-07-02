#!/usr/bin/env sh
# Compile the TypeSpec sources under spec/ into api/openapi-spec/v1.0.yaml.
#
# Assumes a node runtime is available (CI uses node:22-alpine, locally the
# Makefile wraps the script in the same image).
set -eu

cd "$(dirname "$0")/.."/spec

npm ci --prefer-offline --no-audit --no-fund

npx tsp compile .
