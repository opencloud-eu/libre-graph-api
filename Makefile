# libre-graph-api local build entry points.
#
# `make` (or `make spec`) compiles the TypeSpec sources under spec/ into
# api/openapi-spec/v1.0.yaml. Per-language client generation targets pull the
# matching openapi-generator-cli image straight out of the woodpecker pipeline
# file for that language, so renovatebot remains the single source of truth
# for the generator version.

SPEC         := api/openapi-spec/v1.0.yaml
SPEC_SOURCES := $(wildcard spec/*.tsp) spec/tspconfig.yaml spec/package.json spec/package-lock.json
NODE_IMAGE   := node:22-alpine

# Extract `openapitools/openapi-generator-cli:<tag>@sha256:<digest>` from the
# .woodpecker pipeline file for the given language.
#   $(call generator_image,go)
#   $(call generator_image,typescript-axios)
generator_image = $(shell grep -oE "openapitools/openapi-generator-cli:[A-Za-z0-9._@:-]+" .woodpecker/build-$(1).yaml | head -n1)

DOCKER_RUN = docker run --rm \
	--user $(shell id -u):$(shell id -g) \
	-v "$(CURDIR):/work" \
	-w /work

.PHONY: all spec go typescript-axios php cpp-qt-client clean help

all: spec

help: ## Show this help
	@echo "Common commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

spec: $(SPEC) ## Compile TypeSpec sources into api/openapi-spec/v1.0.yaml

$(SPEC): $(SPEC_SOURCES)
	$(DOCKER_RUN) -e HOME=/tmp -e npm_config_cache=/tmp/.npm $(NODE_IMAGE) sh scripts/compile-spec.sh

go: $(SPEC) ## Generate the Go client into build/clients/go
	$(DOCKER_RUN) -e OUTPUT_DIR=build/clients/go $(call generator_image,go) sh scripts/generate-go.sh

typescript-axios: $(SPEC) ## Generate the TypeScript-Axios client into build/clients/typescript-axios
	$(DOCKER_RUN) -e OUTPUT_DIR=build/clients/typescript-axios $(call generator_image,typescript-axios) sh scripts/generate-typescript-axios.sh

php: $(SPEC) ## Generate the PHP client into build/clients/php
	$(DOCKER_RUN) -e OUTPUT_DIR=build/clients/php $(call generator_image,php) sh scripts/generate-php.sh

cpp-qt-client: $(SPEC) ## Generate the C++/Qt client into build/clients/cpp-qt-client
	$(DOCKER_RUN) -e OUTPUT_DIR=build/clients/cpp-qt-client $(call generator_image,cpp-qt) sh scripts/generate-cpp-qt-client.sh

clean: ## Remove build artefacts and the generated spec
	rm -rf build/ spec/build/ $(SPEC)
