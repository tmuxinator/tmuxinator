# Tmuxinator Go - Makefile
# Builds, tests, and packages the tmuxinator Go binary.

BINARY      := tmuxinator
VERSION     := $(shell cat VERSION)
BUILD_DIR   := build
CMD_DIR     := ./cmd/tmuxinator
LDFLAGS     := -ldflags "-X github.com/tmuxinator/tmuxinator/internal/cli/commands.Version=$(VERSION)"

.PHONY: all build test lint clean install release help

## all: Build the binary (default target)
all: build

## build: Build the binary for the current platform
build:
	@mkdir -p $(BUILD_DIR)
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY) $(CMD_DIR)
	@echo "Built $(BUILD_DIR)/$(BINARY)"

## test: Run all tests
test:
	go test ./... -v -count=1

## test-cover: Run tests with coverage report
test-cover:
	go test ./... -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

## lint: Run golangci-lint (requires golangci-lint to be installed)
lint:
	golangci-lint run ./...

## vet: Run go vet
vet:
	go vet ./...

## fmt: Format all Go source files
fmt:
	gofmt -w .

## clean: Remove build artifacts
clean:
	rm -rf $(BUILD_DIR) coverage.out coverage.html

## install: Install the binary to $GOPATH/bin (or ~/go/bin)
install:
	go install $(LDFLAGS) $(CMD_DIR)
	@echo "Installed tmuxinator to $$(go env GOPATH)/bin/$(BINARY)"

## release: Build binaries for all supported platforms
release: clean
	@mkdir -p $(BUILD_DIR)
	@echo "Building release binaries for version $(VERSION)..."

	GOOS=darwin  GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)-darwin-amd64  $(CMD_DIR)
	GOOS=darwin  GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)-darwin-arm64  $(CMD_DIR)
	GOOS=linux   GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)-linux-amd64   $(CMD_DIR)
	GOOS=linux   GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)-linux-arm64   $(CMD_DIR)
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)-windows-amd64.exe $(CMD_DIR)

	@echo "Release binaries:"
	@ls -lh $(BUILD_DIR)/

## deps: Download and tidy Go module dependencies
deps:
	go mod download
	go mod tidy

## help: Show this help message
help:
	@echo "tmuxinator $(VERSION) - Go rewrite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/## /  /'

