#!/bin/bash

# Core "$XCODEPROJ_CLI"-cli compatibility test script
# This script contains the actual test logic and assumes "$XCODEPROJ_CLI" CLI is already installed
# Can be run on any platform where the CLI is available in PATH

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Running xcodeproj-cli core compatibility tests${NC}"

# Use provided executable path or fallback to PATH
XCODEPROJ_CLI="${XCODEPROJ_EXECUTABLE:-xcodeproj}"

# Check if xcodeproj is available
if ! command -v "$XCODEPROJ_CLI" &> /dev/null; then
    echo -e "${RED}❌ xcodeproj CLI not found at: ${XCODEPROJ_CLI}${NC}"
    echo "Please ensure xcodeproj is installed and available"
    exit 1
fi

# Get and display version
VERSION=$("$XCODEPROJ_CLI" --version)
echo -e "${BLUE}📦 Testing "$XCODEPROJ_CLI" CLI version: ${VERSION}${NC}"

# Create temporary directory for tests
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
echo -e "${BLUE}📁 Test directory: ${TEST_DIR}${NC}"

# Function to run test and handle errors
run_test() {
    local test_name="$1"
    local command="$2"
    
    echo -e "${YELLOW}🔧 ${test_name}${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✅ ${test_name} successful${NC}"
    else
        echo -e "${RED}❌ ${test_name} failed${NC}"
        exit 1
    fi
}

# Test 1: Create project
run_test "Project creation" "\"$XCODEPROJ_CLI\" create TestApp --bundle-identifier com.test.app"

# Test 2: Target management
run_test "Add target with all parameters" "\"$XCODEPROJ_CLI\" add-target TestApp.xcodeproj TestFramework framework com.test.framework --platform iOS --deployment-target 15.0"

# Verify targets were created
TARGETS=$("$XCODEPROJ_CLI" list-targets TestApp.xcodeproj)
echo -e "${BLUE}📋 Targets found:${NC}"
echo "$TARGETS"
if [[ "$TARGETS" == *"TestApp"* ]] && [[ "$TARGETS" == *"TestFramework"* ]]; then
    echo -e "${GREEN}✅ Target listing successful${NC}"
else
    echo -e "${RED}❌ Target listing failed${NC}"
    exit 1
fi

# Test 3: Swift Package Manager (with correct positional arguments)
run_test "Add Swift package" "\"$XCODEPROJ_CLI\" add-swift-package TestApp.xcodeproj https://github.com/apple/swift-argument-parser \"from: 1.0.0\" --target-name TestApp --product-name ArgumentParser"

# Verify package was added
PACKAGES=$("$XCODEPROJ_CLI" list-swift-packages TestApp.xcodeproj)
echo -e "${BLUE}📦 Swift packages found:${NC}"
echo "$PACKAGES"
if [[ "$PACKAGES" == *"swift-argument-parser"* ]]; then
    echo -e "${GREEN}✅ Swift package verification successful${NC}"
else
    echo -e "${RED}❌ Swift package verification failed${NC}"
    exit 1
fi

# Test 4: Build phases (with subcommand structure)
run_test "Add run script build phase" "\"$XCODEPROJ_CLI\" add-build-phase run-script TestApp.xcodeproj TestApp \"Test Script\" \"echo 'Build phase test successful'\""

# Test 5: File management
echo -e "${YELLOW}🔧 File management tests${NC}"
echo 'test content for compatibility' > test-file.txt
run_test "Add file to project" "\"$XCODEPROJ_CLI\" add-file TestApp.xcodeproj test-file.txt --target-name TestApp"
run_test "Add copy files build phase" "\"$XCODEPROJ_CLI\" add-build-phase copy-files TestApp.xcodeproj TestApp \"Copy Test Resources\" resources --files test-file.txt"

# Test 6: Build settings
run_test "Set build setting" "\"$XCODEPROJ_CLI\" set-build-setting TestApp.xcodeproj TestApp SWIFT_VERSION 5.9 --configuration Debug"

# Verify build setting was set
SETTINGS=$("$XCODEPROJ_CLI" get-build-settings TestApp.xcodeproj TestApp --configuration Debug)
if [[ "$SETTINGS" == *"SWIFT_VERSION"* ]] && [[ "$SETTINGS" == *"5.9"* ]]; then
    echo -e "${GREEN}✅ Build settings management successful${NC}"
else
    echo -e "${RED}❌ Build settings management failed${NC}"
    exit 1
fi

# Test 7: Additional file operations
echo 'additional test content' > another-file.swift
run_test "Add Swift file" "\"$XCODEPROJ_CLI\" add-file TestApp.xcodeproj another-file.swift --target-name TestApp"

# List files to verify
FILES=$("$XCODEPROJ_CLI" list-files TestApp.xcodeproj TestApp)
echo -e "${BLUE}📄 Files in target:${NC}"
echo "$FILES"
if [[ "$FILES" == *"another-file.swift"* ]]; then
    echo -e "${GREEN}✅ File listing successful${NC}"
else
    echo -e "${RED}❌ File listing failed${NC}"
    exit 1
fi

# Test 8: Build configurations
CONFIGS=$("$XCODEPROJ_CLI" list-build-configurations TestApp.xcodeproj)
echo -e "${BLUE}⚙️  Build configurations:${NC}"
echo "$CONFIGS"
if [[ "$CONFIGS" == *"Debug"* ]] && [[ "$CONFIGS" == *"Release"* ]]; then
    echo -e "${GREEN}✅ Build configuration listing successful${NC}"
else
    echo -e "${RED}❌ Build configuration listing failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 All core compatibility tests passed!${NC}"
echo -e "${GREEN}✨ xcodeproj-cli is fully functional on this platform${NC}"

# Cleanup
cd /
rm -rf "$TEST_DIR"

exit 0