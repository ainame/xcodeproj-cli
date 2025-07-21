#!/bin/bash

# Comprehensive Test Suite for xcodeproj-cli
# Runs both macOS and Linux compatibility tests

set -euo pipefail

echo "🧪 xcodeproj-cli Comprehensive Test Suite"
echo "========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
SKIP_LINUX=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-linux)
            SKIP_LINUX=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--skip-linux]"
            echo ""
            echo "Options:"
            echo "  --skip-linux    Skip Linux compatibility tests"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Track test results
MACOS_RESULT=0
LINUX_RESULT=0

echo -e "${BLUE}📱 Running macOS tests...${NC}"
if ./scripts/test.sh; then
    echo -e "${GREEN}✅ macOS tests passed${NC}"
    MACOS_RESULT=0
else
    echo -e "${RED}❌ macOS tests failed${NC}"
    MACOS_RESULT=1
fi

if [ "$SKIP_LINUX" = false ]; then
    echo -e "${BLUE}🐧 Running Linux compatibility tests...${NC}"
    if ./scripts/test-linux.sh; then
        echo -e "${GREEN}✅ Linux compatibility tests passed${NC}"
        LINUX_RESULT=0
    else
        echo -e "${RED}❌ Linux compatibility tests failed${NC}"
        LINUX_RESULT=1
    fi
else
    echo -e "${YELLOW}⏭️  Skipping Linux compatibility tests${NC}"
fi

echo ""
echo "🏁 Test Results Summary"
echo "======================="

if [ $MACOS_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ macOS tests: PASSED${NC}"
else
    echo -e "${RED}❌ macOS tests: FAILED${NC}"
fi

if [ "$SKIP_LINUX" = false ]; then
    if [ $LINUX_RESULT -eq 0 ]; then
        echo -e "${GREEN}✅ Linux tests: PASSED${NC}"
    else
        echo -e "${RED}❌ Linux tests: FAILED${NC}"
    fi
else
    echo -e "${YELLOW}⏭️  Linux tests: SKIPPED${NC}"
fi

# Overall result
OVERALL_RESULT=$((MACOS_RESULT + LINUX_RESULT))

if [ $OVERALL_RESULT -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! xcodeproj-cli is ready for deployment.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}💥 Some tests failed. Please fix issues before deployment.${NC}"
    exit 1
fi