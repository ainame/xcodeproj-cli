#!/bin/bash

# Linux Compatibility Test Script for xcodeproj-cli
# This script tests the CLI on Linux in a Docker container to ensure full compatibility

set -euo pipefail

echo "🐧 Testing xcodeproj-cli Linux Compatibility"
echo "============================================"

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

echo -e "${BLUE}🚀 Starting Linux compatibility test in Docker...${NC}"

# Run comprehensive Linux test in Docker
docker run --rm -v "$(pwd):/workspace" node:18-bullseye bash -c "
set -euo pipefail
cd /workspace

echo '=== 🏗️  Installing xcodeproj-cli ==='
npm install -g @ainame/xcodeproj-cli 2>&1 | grep -E '(added|warn|error)' || true

echo '=== 📋 Testing version ==='
INSTALLED_VERSION=\$(xcodeproj --version)
echo \"Installed version: \$INSTALLED_VERSION\"

echo '=== 🎯 Creating test project ==='
xcodeproj create TestApp --bundle-identifier com.test.app
echo '✅ Project creation successful'

echo '=== 🎯 Testing target management ==='
# Test add-target with all required parameters
xcodeproj add-target TestApp.xcodeproj TestFramework framework com.test.framework --platform iOS --deployment-target 15.0
echo '✅ Target creation successful'

# Test target listing  
TARGETS=\$(xcodeproj list-targets TestApp.xcodeproj)
echo \"Targets found: \$TARGETS\"
if [[ \"\$TARGETS\" == *\"TestApp\"* ]] && [[ \"\$TARGETS\" == *\"TestFramework\"* ]]; then
    echo '✅ Target listing successful'
else
    echo '❌ Target listing failed'
    exit 1
fi

echo '=== 📦 Testing Swift Package Manager ==='
# Test add-swift-package with correct positional arguments
xcodeproj add-swift-package TestApp.xcodeproj https://github.com/apple/swift-argument-parser \"from: 1.0.0\" --target-name TestApp --product-name ArgumentParser
echo '✅ Swift package addition successful'

# Verify package was added
PACKAGES=\$(xcodeproj list-swift-packages TestApp.xcodeproj)
echo \"Swift packages found: \$PACKAGES\"
if [[ \"\$PACKAGES\" == *\"swift-argument-parser\"* ]]; then
    echo '✅ Swift package verification successful'
else
    echo '❌ Swift package verification failed'
    exit 1
fi

echo '=== 🔧 Testing build phases ==='
# Test add-build-phase with subcommand structure
xcodeproj add-build-phase run-script TestApp.xcodeproj TestApp \"Test Script\" \"echo 'Linux build test successful'\"
echo '✅ Run script build phase successful'

# Create test file for copy-files build phase
echo 'test content for Linux' > test-file.txt
xcodeproj add-file TestApp.xcodeproj test-file.txt --target-name TestApp
xcodeproj add-build-phase copy-files TestApp.xcodeproj TestApp \"Copy Test Resources\" resources --files test-file.txt
echo '✅ Copy files build phase successful'

echo '=== ⚙️  Testing build settings ==='
xcodeproj set-build-setting TestApp.xcodeproj TestApp SWIFT_VERSION 5.9 --configuration Debug
SETTINGS=\$(xcodeproj get-build-settings TestApp.xcodeproj TestApp --configuration Debug)
if [[ \"\$SETTINGS\" == *\"SWIFT_VERSION\"* ]] && [[ \"\$SETTINGS\" == *\"5.9\"* ]]; then
    echo '✅ Build settings management successful'
else
    echo '❌ Build settings management failed'
    exit 1
fi

echo '=== 📁 Testing file management ==='
# Test file operations
echo 'additional test content' > another-file.swift
xcodeproj add-file TestApp.xcodeproj another-file.swift --target-name TestApp
xcodeproj list-files TestApp.xcodeproj TestApp > file-list.txt
if grep -q 'another-file.swift' file-list.txt; then
    echo '✅ File management successful'
else
    echo '❌ File management failed' 
    exit 1
fi

echo '=== 🏁 All Linux compatibility tests passed! ==='
echo 'xcodeproj-cli is fully compatible with Linux environments'
"

# Get exit code from Docker run
DOCKER_EXIT_CODE=$?

# Cleanup
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $DOCKER_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Linux compatibility test completed successfully!${NC}"
    echo -e "${GREEN}🚀 xcodeproj-cli is ready for Linux deployment${NC}"
    exit 0
else
    echo -e "${RED}❌ Linux compatibility test failed${NC}"
    echo -e "${RED}🔧 Please check the error messages above${NC}"
    exit 1
fi