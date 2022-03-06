.DEFAULT_GOAL := help

define setup
	bash -c 'rm -rf artifacts && mkdir -p artifacts'		# Circle CI builds on a remote docker engine - "artifacts" directly must exist
	docker build -t wd-perf:latest .
endef

.PHONY: run-local
run-local: ## Run test locally, runs sample test by default, e.g. FILE_TO_EXECUTE=<path to file> make run-local
	$(call setup)
	RUN_ON=local bash ./scripts/run-tests 

.PHONY: run-cloud
run-cloud: ## Run test on Blazemeter, e.g. NAME=<test name on blazemeter> FILE_TO_EXECUTE=<path to file> make run-cloud
	@[ "$(API_TOKEN)" ] || ( echo ">> Blazemeter 'API_TOKEN' is not set"; exit 1 )
	@[ "$(FILE_TO_EXECUTE)" ] || ( echo ">> 'FILE_TO_EXECUTE' is not set"; exit 1 )
	$(call setup)
	RUN_ON=cloud bash ./scripts/run-tests 

.PHONY: copy-artifacts
copy-artifacts: ## Copies test files, logs and reports to local, e.g. ARTIFACTS_PATH=./artifacts make copy-artifacts
	@[ "$(ARTIFACTS_PATH)" ] || ( echo ">> Path 'ARTIFACTS_PATH' is not set"; exit 1 )
	docker cp wd-perf-container:/tmp/artifacts $(ARTIFACTS_PATH)

.PHONY: lint
lint: ## Lint test scripts from entrypoint FILE_TO_EXECUTE
	$(call setup)
	LINT=true bash ./scripts/run-tests

.PHONY: validate-circleci
validate-circleci:  ## Validates the circleci config at ./circleci/config.yaml e.g. TOKEN=<TOKEN> make validate-circleci
	@[ "$(TOKEN)" ] || ( echo ">> CircleCI Token 'TOKEN' is not set"; exit 1 )
	docker run --rm -v $(shell pwd):/data circleci/circleci-cli:alpine config validate /data/.circleci/config.yml --token $(TOKEN)

.PHONY: generate-data-sources
generate-data-sources:  ## Generates dynamic data-sources. i.e. podcasts-generated.csv. required envs: GRAPH_URL, AUTH0_TOKEN
	GENERATED_DATASOURCE_FILE=$(shell pwd)/tests/data/podcasts-generated.csv ./scripts/generate-data-sources

# ===

.PHONY: help
help: # parse jobs and descriptions from this Makefile
	@grep -E '^[ a-zA-Z0-9_-]+:([^=]|$$)' $(MAKEFILE_LIST) \
		| grep -Ev '^(help)\b[[:space:]]*:' \
		| awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m \t%s\n", $$1, $$2}'
