#!/bin/bash

# Docker-based Linux Compatibility Test Script for xcodeproj-cli
# This script tests the CLI on Linux in a Docker container (for local development on macOS/Windows)
# For CI/CD on Linux, use test-linux-native.sh instead to avoid Docker-in-Docker overhead

set -euo pipefail

echo "🐧 Testing xcodeproj-cli Linux Compatibility (Docker)"
echo "==================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
    echo "Please install Docker to run Linux compatibility tests"
    echo "Alternatively, if running on Linux, use scripts/test-linux-native.sh"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running${NC}"
    echo "Please start Docker daemon to run Linux compatibility tests"
    exit 1
fi

echo -e "${BLUE}🔍 Checking Docker availability...${NC}"
echo -e "${GREEN}✅ Docker is available and running${NC}"

# Get the current version from Command.swift
VERSION=$(grep 'version:' Sources/xcodeproj-cli/Command.swift | sed 's/.*version: "\([^"]*\)".*/\1/')
echo -e "${BLUE}📦 Testing version: ${VERSION}${NC}"

# Create temporary directory for test
TEST_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Test directory: ${TEST_DIR}${NC}"

# Copy necessary files for testing
cp -r . "$TEST_DIR/"
cd "$TEST_DIR"

# Ensure test scripts are executable
chmod +x scripts/test-core.sh scripts/test-linux.sh scripts/test-linux-native.sh 2>/dev/null || true

echo -e "${BLUE}🚀 Starting Linux compatibility test in Docker...${NC}"

# Run Linux test in Docker using the core test script
docker run --rm -v "$(pwd):/workspace" node:18-bullseye bash -c "
set -euo pipefail
cd /workspace

echo '=== 🏗️  Installing xcodeproj-cli ==='
npm install -g @ainame/xcodeproj-cli 2>&1 | grep -E '(added|warn|error)' || true

echo '=== 📋 Verifying installation ==='
if command -v xcodeproj &> /dev/null; then
    INSTALLED_VERSION=\$(xcodeproj --version)
    echo \"✅ Installed version: \$INSTALLED_VERSION\"
else
    echo '❌ xcodeproj-cli installation failed'
    exit 1
fi

echo '=== 🧪 Running core compatibility tests ==='
# Make the core test script executable and run it
if [ -f scripts/test-core.sh ]; then
    chmod +x scripts/test-core.sh
    ./scripts/test-core.sh
else
    echo '❌ scripts/test-core.sh not found in workspace'
    echo 'Current directory contents:'
    ls -la
    echo 'Scripts directory contents:'
    ls -la scripts/ || echo 'scripts directory not found'
    echo 'Searching for test-core.sh:'
    find . -name 'test-core.sh' -type f || echo 'test-core.sh not found anywhere'
    exit 1
fi
"

# Get exit code from Docker run
DOCKER_EXIT_CODE=$?

# Cleanup
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $DOCKER_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Docker-based Linux compatibility test completed successfully!${NC}"
    echo -e "${GREEN}🚀 xcodeproj-cli is ready for Linux deployment${NC}"
    exit 0
else
    echo -e "${RED}❌ Docker-based Linux compatibility test failed${NC}"
    echo -e "${RED}🔧 Please check the error messages above${NC}"
    exit 1
fi