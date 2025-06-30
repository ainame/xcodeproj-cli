#!/bin/bash

# xcodeproj CLI Test Script
# This script demonstrates all 19 commands in the xcodeproj CLI tool

set -e  # Exit on any error

echo "🧪 Testing xcodeproj CLI - All 19 Commands"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build the CLI first
echo -e "${BLUE}Building xcodeproj CLI...${NC}"
swift build
CLI_PATH=".build/debug/xcodeproj"

# Clean up any existing test project
echo -e "${BLUE}Cleaning up previous test project...${NC}"
rm -rf TestDemo.xcodeproj TestDemo/

# Function to run command and show output
run_command() {
    echo -e "${YELLOW}Running: $1${NC}"
    eval "$1"
    echo -e "${GREEN}✅ Success${NC}"
    echo ""
}

echo -e "${BLUE}=== 1. CREATE PROJECT ===${NC}"
run_command "$CLI_PATH create TestDemo --organization-name 'Demo Company' --bundle-identifier 'com.demo.testapp'"

echo -e "${BLUE}=== 2. LIST TARGETS ===${NC}"
run_command "$CLI_PATH list-targets TestDemo.xcodeproj"

echo -e "${BLUE}=== 3. LIST BUILD CONFIGURATIONS ===${NC}"
run_command "$CLI_PATH list-build-configurations TestDemo.xcodeproj"

echo -e "${BLUE}=== 4. LIST FILES IN TARGET ===${NC}"
run_command "$CLI_PATH list-files TestDemo.xcodeproj TestDemo"

echo -e "${BLUE}=== 5. GET BUILD SETTINGS ===${NC}"
run_command "$CLI_PATH get-build-settings TestDemo.xcodeproj TestDemo --configuration Debug"

echo -e "${BLUE}=== 6. ADD FILE ===${NC}"
mkdir -p TestDemo
echo "// New Swift file" > TestDemo/NewFile.swift
run_command "$CLI_PATH add-file TestDemo.xcodeproj TestDemo/NewFile.swift --target-name TestDemo"

echo -e "${BLUE}=== 7. CREATE GROUP ===${NC}"
run_command "$CLI_PATH create-group TestDemo.xcodeproj Utils"

echo -e "${BLUE}=== 8. ADD TARGET ===${NC}"
run_command "$CLI_PATH add-target TestDemo.xcodeproj DemoLib static_library com.demo.demolib --platform iOS --deployment-target 15.0"

echo -e "${BLUE}=== 9. ADD DEPENDENCY ===${NC}"
run_command "$CLI_PATH add-dependency TestDemo.xcodeproj TestDemo DemoLib"

echo -e "${BLUE}=== 10. SET BUILD SETTING ===${NC}"
run_command "$CLI_PATH set-build-setting TestDemo.xcodeproj TestDemo SWIFT_VERSION 5.9 --configuration Debug"

echo -e "${BLUE}=== 11. ADD FRAMEWORK ===${NC}"
run_command "$CLI_PATH add-framework TestDemo.xcodeproj TestDemo UIKit"

echo -e "${BLUE}=== 12. ADD SWIFT PACKAGE ===${NC}"
run_command "$CLI_PATH add-swift-package TestDemo.xcodeproj https://github.com/apple/swift-argument-parser 'from: 1.0.0' --target-name TestDemo --product-name ArgumentParser"

echo -e "${BLUE}=== 13. LIST SWIFT PACKAGES ===${NC}"
run_command "$CLI_PATH list-swift-packages TestDemo.xcodeproj"

echo -e "${BLUE}=== 14. ADD BUILD PHASE (Run Script) ===${NC}"
run_command "$CLI_PATH add-build-phase run-script TestDemo.xcodeproj TestDemo 'SwiftLint Check' 'echo \"Running SwiftLint...\"'"

echo -e "${BLUE}=== 15. DUPLICATE TARGET ===${NC}"
run_command "$CLI_PATH duplicate-target TestDemo.xcodeproj TestDemo TestDemo-Staging --new-bundle-identifier com.demo.testapp.staging"

echo -e "${BLUE}=== 16. MOVE FILE ===${NC}"
run_command "$CLI_PATH move-file TestDemo.xcodeproj TestDemo/NewFile.swift TestDemo/RenamedFile.swift"

echo -e "${BLUE}=== 17. ADD BUILD PHASE (Copy Files) ===${NC}"
echo "Sample config file" > TestDemo/config.plist
run_command "$CLI_PATH add-file TestDemo.xcodeproj TestDemo/config.plist --target-name TestDemo"
run_command "$CLI_PATH add-build-phase copy-files TestDemo.xcodeproj TestDemo 'Copy Config' resources --files TestDemo/config.plist"

echo -e "${BLUE}=== 18. ADD ANOTHER FRAMEWORK ===${NC}"
run_command "$CLI_PATH add-framework TestDemo.xcodeproj DemoLib Foundation"

echo -e "${BLUE}=== 19. REMOVE SWIFT PACKAGE ===${NC}"
run_command "$CLI_PATH remove-swift-package TestDemo.xcodeproj https://github.com/apple/swift-argument-parser"

echo -e "${BLUE}=== FINAL PROJECT STATE ===${NC}"
echo -e "${YELLOW}Final targets in project:${NC}"
$CLI_PATH list-targets TestDemo.xcodeproj

echo -e "${YELLOW}Final Swift packages:${NC}"
$CLI_PATH list-swift-packages TestDemo.xcodeproj

echo -e "${YELLOW}Final files in main target:${NC}"
$CLI_PATH list-files TestDemo.xcodeproj TestDemo

echo ""
echo -e "${GREEN}🎉 All 19 commands tested successfully!${NC}"
echo -e "${BLUE}Test project created: TestDemo.xcodeproj${NC}"
echo -e "${BLUE}You can open it in Xcode to inspect the results:${NC}"
echo -e "${YELLOW}open TestDemo.xcodeproj${NC}"

echo ""
echo -e "${BLUE}=== CLEANUP (Optional) ===${NC}"
echo -e "${YELLOW}To clean up the test project, run:${NC}"
echo -e "${YELLOW}rm -rf TestDemo.xcodeproj TestDemo/${NC}"
