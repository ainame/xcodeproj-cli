#!/bin/bash

# Native Linux compatibility test script for GitHub Actions
# Builds and tests the actual Swift code on Linux without Docker overhead

set -euo pipefail

echo "🐧 Building and Testing xcodeproj-cli on Native Linux"
echo "===================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}❌ This script is designed to run on Linux${NC}"
    echo "Current OS: $OSTYPE"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo -e "${RED}❌ Swift is not installed${NC}"
    echo "Please install Swift for Linux"
    exit 1
fi

echo -e "${BLUE}📋 Swift version information:${NC}"
swift --version

echo -e "${BLUE}🔨 Building xcodeproj-cli from source...${NC}"

# Build debug version first to catch any build issues
echo -e "${YELLOW}Building debug version...${NC}"
if ! swift build -v; then
    echo -e "${RED}❌ Debug build failed${NC}"
    exit 1
fi

# Build release version for testing
echo -e "${YELLOW}Building release version...${NC}"
if ! swift build -c release -v; then
    echo -e "${RED}❌ Release build failed${NC}"
    exit 1
fi

# Verify the executable was created
EXECUTABLE_PATH=".build/release/xcodeproj"
if [[ ! -f "$EXECUTABLE_PATH" ]]; then
    echo -e "${RED}❌ Executable not found at $EXECUTABLE_PATH${NC}"
    exit 1
fi

# Make executable and test basic functionality
chmod +x "$EXECUTABLE_PATH"

echo -e "${GREEN}✅ xcodeproj-cli built successfully${NC}"

# Test basic commands
echo -e "${BLUE}🧪 Testing basic commands...${NC}"

# Test version command
echo -e "${YELLOW}Testing --version...${NC}"
BUILT_VERSION=$("$EXECUTABLE_PATH" --version)
echo -e "${BLUE}📦 Built version: ${BUILT_VERSION}${NC}"

# Test help command
echo -e "${YELLOW}Testing --help...${NC}"
"$EXECUTABLE_PATH" --help > /dev/null

echo -e "${GREEN}✅ Basic commands work correctly${NC}"

echo -e "${BLUE}🚀 Running core compatibility tests...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export the executable path for test-core.sh to use
export XCODEPROJ_EXECUTABLE="$(pwd)/$EXECUTABLE_PATH"

# Run the core test script
if "$SCRIPT_DIR/test-core.sh"; then
    echo -e "${GREEN}🎉 Native Linux compatibility tests completed successfully!${NC}"
    echo -e "${GREEN}✨ xcodeproj-cli is fully compatible with Linux environments${NC}"
    exit 0
else
    echo -e "${RED}❌ Native Linux compatibility tests failed${NC}"
    echo -e "${RED}💥 Please check the error messages above${NC}"
    exit 1
fi