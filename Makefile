# MAKEFILE
#
# @author      Sam Craig <sam@lunaris.io>
# @link        https://github.com/lunaris-studios/mirror
# ------------------------------------------------------------------------------

.EXPORT_ALL_VARIABLES:

# Display general help about this command
.PHONY: help
help:
	@echo ""
	@echo "Welcome to the '$(PROJECT)' Makefile."
	@echo ""
	@echo "The following commands are available:"
	@echo ""
	@echo "    make run                   : Run the application"
	@echo "    make run-build             : Run compiled local binary"
	@echo ""
	@echo "    make test                  : Run all unit, QA, and static analysis reports"
	@echo "    make test-unit             : Run unit tests"
	@echo ""
	@echo "    make deps                  : Get all project dependencies"
	@echo "    make deps-go               : Get all go dependencies"
	@echo "    make deps-npm              : Get all npm dependencies"
	@echo ""
	@echo "    make build                 : Compile the application for the user's current platform"
	@echo "    make build-cross           : Cross-compile the application for several platforms"
	@echo ""
	@echo "    make docker-run          : Run the application in docker"
	@echo "    make docker-build        : Compile the application in docker"
	@echo "    make docker-build-cross  : Cross-compile the application for several platforms in docker"
	@echo ""
	@echo "    make release               : Create a new release via 'semantic-release'"
	@echo ""
	@echo "    make clean                 : Remove all project artifacts"
	@echo "    make clean-build           : Remove all build artifacts"
	@echo "    make clean-config          : Remove all configuration artifacts"
	@echo "    make clean-deps            : Remove all dependency artifacts"
	@echo ""
	@echo "    make update                : Update project dependencies"
	@echo "    make update-nix            : Update niv sources"
	@echo "    make update-npm            : Update npm dependencies"
	@echo ""

all: help

# === Entities ===

# URL of the remote repository
REPOSITORY := $$PROJECT_REPOSITORY

# Project owner
OWNER := $$PROJECT_OWNER

# Project name
PROJECT := $$PROJECT_NAME

# Project version
VERSION := $$PROJECT_VERSION

# Project commit hash
COMMIT := $(shell git rev-parse HEAD)

# Project vendor
VENDOR := $(NAME)-vendor

# Name of RPM or DEB package
PKGNAME := $(VENDOR)-$(NAME)

# Cross compilation targets
CCTARGETS := darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm openbsd/386 openbsd/amd64 windows/386 windows/amd64

# STATIC is a flag to indicate whether to build using static or dynamic linking
STATIC=1
ifeq ($(STATIC),0)
	STATIC_TAG=dynamic
	STATIC_FLAG=
else
	STATIC_TAG=static
	STATIC_FLAG=-static
endif

# === Shell Configuration ===

SHELL := $(shell which bash)

UNAME_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
UNAME_ARCH := $(shell uname -m | tr '[:upper:]' '[:lower:]')

TMP_BASE := vendor
TMP := $(TMP_BASE)
TMP_BIN = $(TMP)/bin
TMP_VERSIONS := $(TMP)/versions

# === Environment ===

STAGE ?= development

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CONFIG_DIR := $(ROOT_DIR)/config
SETTINGS_DIR := $(CONFIG_DIR)/settings
TARGET_DIR := $(ROOT_DIR)/target

# Combine the active project stage configuration settings
# with the included `global.json` configuartion settings.
STAGE_SETTINGS := $(SETTINGS_DIR)/$(STAGE).json
GLOBAL_SETTINGS := $(SETTINGS_DIR)/global.json

export PATH := $(PATH):$(TARGET_DIR)

.PHONY: .env.json
.env.json:
	@jq -s '.[0] * .[1]' $(STAGE_SETTINGS) $(GLOBAL_SETTINGS) > .env.json

# Export `.tool-versions` entries as environment variables
# with the pattern "<DEPENDENCY_NAME>_VERSION=<DEPENDENCY_VERSION>"
# to the temp file `.tool-versiions.env`
include .tool-versions.env
.PHONY: .tool-versions.env
.tool-versions.env: .tool-versions
	@(sed -e 's/\(.*\)\ \(.*\)/\1_VERSION=\2/g' | tr '[:lower:]' '[:upper:]') < $< > $@

include .env
.PHONY: .env
.env: .env.json
	@(python ./scripts/python/jsontoenv.py) < $< > $@

.PHONY: .env.yaml
.env.yaml: .env.json
	@(python ./scripts/python/jsontoyaml.py) < $< > $@

# === Run ===

.PHONY: run
run:
	go run ./cmd/$(PROJECT)

.PHONY: run-build
run-build:
	./target/dist/bin/$(PROJECT)

# === Testing ===

# Run all unit, QA, and static analysis reports
.PHONY: test
test: setup-test
	@$(MAKE) -s test-unit          || true
	@$(MAKE) -s test-golangci-lint || true

# Run unit tests
.PHONY: test-unit
test-unit:
	@go test -tags ${STATIC_TAG} \
	-covermode=atomic \
	-bench=. \
	-race \
	-coverprofile=target/test/coverage.out \
	-v ./...

.PHONY: test-golangci-lint
test-golangci-lint:
	@golangci-lint run \
		--verbose \
		--out-format "junit-xml" \
		--mem-profile-path ./target/test/mem-profile.out \
		--cpu-profile-path ./target/test/cpu-profile.out \
		--trace-path ./target/test/trace.out \
		--fix | tee ./target/test/coverage.xml

# === Setup ===

.PHONY: setup
setup:
	@$(MAKE) -s setup-build
	@$(MAKE) -s setup-docs
	@$(MAKE) -s setup-nix
	@$(MAKE) -s setup-test

.PHONY: setup-build
setup-build:
	@test -d ./target/dist || \
		mkdir -p ./target/dist
	@test -d ./target/dist/bin || \
		mkdir -p ./target/dist/bin


# Stub macro to call top-level config generators
.PHONY: setup-config
setup-config:
	@exit

.PHONY: setup-docs
setup-docs:
	@go get golang.org/x/tools/cmd/godoc
	@test -d ./target/docs || \
		mkdir -p ./target/docs

.PHONY: setup-nix
setup-nix:
	lorri watch &

.PHONY: setup-test
setup-test:
	@test -d ./target/test || \
		mkdir -p ./target/test

# === Dependencies ===

# Get all project dependencies
.PHONY: deps
deps:
	@$(MAKE) -s deps-go
	@$(MAKE) -s deps-npm

# Get all Go dependencies
.PHONY: deps-go
deps-go:
	go mod download && go mod vendor

# Get all NPM dependencies
.PHONY: deps-npm
deps-npm:
	npm install

# === Build ===

# Compile the application relative to the user's OS.
build:
	GO111MODULE=on \
	CGO_ENABLED=0 \
		go build \
		-ldflags '-extldflags "-fno-PIC $(STATIC_FLAG)" -w -s -X release.version=$(VERSION) -X release.commit=$(COMMIT)' \
		-mod=readonly \
		-v -o ./target/dist/bin/$(PROJECT) ./cmd/$(PROJECT) \
		&& chmod +x ./target/dist/bin/$(PROJECT)

# Cross-compile the application for several platforms
.PHONY: build-cross
build-cross: setup-build
	@echo "" > target/dist/ccfailures.txt
	$(foreach TARGET,$(CCTARGETS), \
		$(eval GOOS = $(word 1,$(subst /, ,$(TARGET)))) \
		$(eval GOARCH = $(word 2,$(subst /, ,$(TARGET)))) \
		$(shell which mkdir) -p target/dist/$(TARGET) && \
		GO111MODULE=on\
		CGO_ENABLED=0 \
		GOOS=$(GOOS) \
		GOARCH=$(GOARCH) \
		go build \
		-tags $(STATIC_TAG) \
		-ldflags '-s -extldflags $(STATIC_FLAG) -w -s -X release.version=$(VERSION) -X release.commit=$(COMMIT)' \
		-o ./target/dist/$(GOOS)/$(GOARCH)/$(PROJECT) ./cmd/$(PROJECT) \
		|| echo $(TARGET) >> ./target/dist/ccfailures.txt ; \
	)
ifneq ($(strip $(cat ./target/dist/ccfailures.txt)),)
	echo ./target/dist/ccfailures.txt
	exit 1
endif

# === Docker ===

.PHONY: docker-run
docker-run:
	docker build \
		--file ./docker/run.dockerfile \
		--tag $(PROJECT) \
		--build-arg COMMIT=$(COMMIT) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg OS=$(OS) \
		--build-arg PROJECT=$(PROJECT) \
		--build-arg STATIC_FLAG=$(STATIC_FLAG) \
		.
	docker run --interactive --rm --tty $(PROJECT)

.PHONY: docker-build
docker-build: setup-build
	@docker build \
		--file ./docker/build.dockerfile \
		--tag $(PROJECT) \
		--build-arg COMMIT=$(COMMIT) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg OS=$(OS) \
		--build-arg PROJECT=$(PROJECT) \
		--build-arg STATIC_FLAG=$(STATIC_FLAG) \
		.
	# TODO (sam): replace w/ $(PROJECT) shim		
	$(eval CONTAINER_ID := $(shell docker create mirror:latest))
	@docker cp $(CONTAINER_ID):/app/target/dist/bin/$(PROJECT) ./target/dist/bin/$(PROJECT)
	@docker rm --volumes $(CONTAINER_ID)

# Cross-compile the application for several platforms in Docker
.PHONY: docker-build-cross
docker-build-cross: setup-build
	@echo "" > target/dist/ccfailures.txt
	$(foreach TARGET,$(CCTARGETS), \
		$(eval GOOS = $(word 1,$(subst /, ,$(TARGET)))) \
		$(eval GOARCH = $(word 2,$(subst /, ,$(TARGET)))) \
		$(shell which mkdir) --parents ./target/dist/$(TARGET) && \
		docker build \
			--file ./docker/build.dockerfile \
			--tag $(PROJECT) \
			--build-arg ARCH=$(ARCH) \
			--build-arg COMMIT=$(GOARCH) \
			--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
			--build-arg OS=$(GOOS) \
			--build-arg PROJECT=$(PROJECT) \
			--build-arg STATIC_FLAG=$(STATIC_FLAG) \
			. && \
		$(eval CONTAINER_ID := $(shell docker create mirror:latest)) \
			docker cp $(CONTAINER_ID):/app/target/dist/bin/$(PROJECT) ./target/dist/$(GOOS)/$(GOARCH) && \
			docker rm --volumes $(CONTAINER_ID) \
			|| echo $(TARGET) >> ./target/dist/ccfailures.txt ; \
	)
ifneq ($(strip $(cat ./target/dist/ccfailures.txt)),)
	echo ./target/dist/ccfailures.txt
	exit 1
endif	

# === Release ===

# This command should only ever be run in CI,
# refrain from using this locally.
.PHONY: release
release:
	@npm run release

# === Clean ===

# Remove all project artifacts
#
# Configuration cleanup needs to be last in our order of execution, because
# all configuration files are built per make command.
.PHONY: clean
clean:
	@$(MAKE) -s clean-builds
	@$(MAKE) -s clean-deps
	@$(MAKE) -s clean-config

# Remove all build artifacts
.PHONY: clean-builds
clean-builds:
	@rm -rf ./target

# Remove all configuration artifacts
.PHONY: clean-config
clean-config:
	@rm -f .env.json .env .env.yaml .tool-versions.env

# Remove all dependency artifacts
.PHONY: clean-deps
clean-deps:
	@rm -rf ./vendor

# === Update ===

# Update all project dependencies
.PHONY: update
update:
	@$(MAKE) -s update-niv
	@$(MAKE) -s update-npm

# Update niv dependencies
.PHONY: update-niv
update-niv:
	@niv update

# Update npm packages
.PHONY: update-npm
update-npm:
	@npm run update
