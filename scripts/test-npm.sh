#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Testing npm Distribution ===${NC}"

# Save current directory
ORIGINAL_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to cleanup
cleanup() {
    cd "$ORIGINAL_DIR"
    # Clean up any test artifacts
    rm -rf "$PROJECT_ROOT/tmp/npm-test"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Create test workspace
TEST_DIR="$PROJECT_ROOT/tmp/npm-test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo -e "\n${BLUE}1. Building the project first...${NC}"
cd "$PROJECT_ROOT"
swift build -c release

# Ensure binaries directory exists and copy the binary
BINARY_NAME="xcodeproj"
if [[ "$OSTYPE" == "darwin"* ]]; then
    BINARY_NAME="xcodeproj-macos-universal"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        BINARY_NAME="xcodeproj-linux-x86_64"
    else
        BINARY_NAME="xcodeproj-linux-aarch64"
    fi
fi

echo -e "\n${BLUE}2. Setting up binary for npm wrapper...${NC}"
mkdir -p "$PROJECT_ROOT/binaries"
cp "$PROJECT_ROOT/.build/release/xcodeproj" "$PROJECT_ROOT/binaries/$BINARY_NAME"
chmod +x "$PROJECT_ROOT/binaries/$BINARY_NAME"

echo -e "\n${BLUE}3. Testing direct wrapper.js execution...${NC}"
cd "$TEST_DIR"

# Test help command
echo -e "   Testing: node wrapper.js --help"
if node "$PROJECT_ROOT/npm/wrapper.js" --help > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓ Direct wrapper execution works${NC}"
else
    echo -e "   ${RED}✗ Direct wrapper execution failed${NC}"
    exit 1
fi

# Test version command
echo -e "   Testing: node wrapper.js --version"
VERSION_OUTPUT=$(node "$PROJECT_ROOT/npm/wrapper.js" --version 2>&1)
if [[ $? -eq 0 ]]; then
    echo -e "   ${GREEN}✓ Version command works: $VERSION_OUTPUT${NC}"
else
    echo -e "   ${RED}✗ Version command failed${NC}"
    exit 1
fi

echo -e "\n${BLUE}4. Testing npm link simulation...${NC}"
cd "$PROJECT_ROOT"

# Create a temporary node_modules structure to simulate npm install
TEST_INSTALL_DIR="$TEST_DIR/test-install"
mkdir -p "$TEST_INSTALL_DIR/node_modules/.bin"
mkdir -p "$TEST_INSTALL_DIR/node_modules/@ainame/xcodeproj-cli/npm"

# Copy package files
cp "$PROJECT_ROOT/package.json" "$TEST_INSTALL_DIR/node_modules/@ainame/xcodeproj-cli/"
cp "$PROJECT_ROOT/npm/wrapper.js" "$TEST_INSTALL_DIR/node_modules/@ainame/xcodeproj-cli/npm/"

# Copy binaries directory too (simulating post-install)
cp -r "$PROJECT_ROOT/binaries" "$TEST_INSTALL_DIR/node_modules/@ainame/xcodeproj-cli/"

# Create symlink in .bin (this is what npm does)
cd "$TEST_INSTALL_DIR/node_modules/.bin"
ln -sf "../@ainame/xcodeproj-cli/npm/wrapper.js" xcodeproj
chmod +x xcodeproj

# Test the symlinked command
cd "$TEST_INSTALL_DIR"
echo -e "   Testing: ./node_modules/.bin/xcodeproj --help"
if ./node_modules/.bin/xcodeproj --help > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓ npm-style symlink execution works${NC}"
else
    echo -e "   ${RED}✗ npm-style symlink execution failed${NC}"
    # Show error for debugging
    echo -e "   Debug: Running command with error output:"
    ./node_modules/.bin/xcodeproj --help || true
    exit 1
fi

echo -e "\n${BLUE}5. Testing with a sample project...${NC}"
cd "$TEST_DIR"

# Create a test project
echo -e "   Creating test project..."
node "$PROJECT_ROOT/npm/wrapper.js" create TestProject --bundle-identifier com.example.test

if [ -d "TestProject.xcodeproj" ]; then
    echo -e "   ${GREEN}✓ Project created successfully${NC}"
    
    # Test listing targets
    echo -e "   Testing: list-targets"
    TARGETS=$(node "$PROJECT_ROOT/npm/wrapper.js" list-targets TestProject.xcodeproj)
    if [[ "$TARGETS" == *"TestProject"* ]]; then
        echo -e "   ${GREEN}✓ list-targets works${NC}"
    else
        echo -e "   ${RED}✗ list-targets failed${NC}"
        exit 1
    fi
else
    echo -e "   ${RED}✗ Failed to create project${NC}"
    exit 1
fi

echo -e "\n${BLUE}6. Testing error handling...${NC}"
# Test with missing binary
mv "$PROJECT_ROOT/binaries/$BINARY_NAME" "$PROJECT_ROOT/binaries/${BINARY_NAME}.bak"
ERROR_OUTPUT=$(node "$PROJECT_ROOT/npm/wrapper.js" --help 2>&1 || true)
if [[ "$ERROR_OUTPUT" == *"not found"* ]] && [[ "$ERROR_OUTPUT" == *"reinstall"* ]]; then
    echo -e "   ${GREEN}✓ Proper error message when binary is missing${NC}"
else
    echo -e "   ${RED}✗ Error handling not working properly${NC}"
    echo "   Got: $ERROR_OUTPUT"
fi
# Restore binary
mv "$PROJECT_ROOT/binaries/${BINARY_NAME}.bak" "$PROJECT_ROOT/binaries/$BINARY_NAME"

echo -e "\n${GREEN}=== All npm distribution tests passed! ===${NC}"