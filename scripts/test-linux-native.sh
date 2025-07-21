#!/bin/bash

# Native Linux compatibility test script for GitHub Actions
# Runs directly on Linux without Docker overhead

set -euo pipefail

echo "🐧 Testing xcodeproj-cli on Native Linux"
echo "======================================="

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

# Check if Node.js is available
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    echo "Please install Node.js and npm"
    exit 1
fi

echo -e "${BLUE}🔍 Installing xcodeproj-cli from npm...${NC}"

# Install the CLI globally
npm install -g @ainame/xcodeproj-cli

# Verify installation
if command -v xcodeproj &> /dev/null; then
    echo -e "${GREEN}✅ xcodeproj-cli installed successfully${NC}"
    INSTALLED_VERSION=$(xcodeproj --version)
    echo -e "${BLUE}📦 Installed version: ${INSTALLED_VERSION}${NC}"
else
    echo -e "${RED}❌ xcodeproj-cli installation failed${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Running core compatibility tests...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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