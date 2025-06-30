#!/bin/bash

# xcodeproj CLI Installation Script
# Automatically downloads and installs the latest release

set -e

# Configuration
REPO="ainame/xcodeproj_cli"
BINARY_NAME="xcodeproj"
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This tool only supports macOS"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
log_info "Detected architecture: $ARCH"

# Get latest release version
log_info "Fetching latest release information..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    log_error "Failed to fetch latest version"
    exit 1
fi

log_info "Latest version: $LATEST_VERSION"

# Download URL for universal binary
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/${BINARY_NAME}-${LATEST_VERSION}-macos-universal.tar.gz"
CHECKSUMS_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/${BINARY_NAME}-${LATEST_VERSION}-checksums.txt"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

log_info "Downloading $BINARY_NAME $LATEST_VERSION..."
if ! curl -L -o "${BINARY_NAME}.tar.gz" "$DOWNLOAD_URL"; then
    log_error "Failed to download $BINARY_NAME"
    exit 1
fi

log_info "Downloading checksums..."
if ! curl -L -o "checksums.txt" "$CHECKSUMS_URL"; then
    log_warning "Failed to download checksums, skipping verification"
else
    log_info "Verifying checksums..."
    if shasum -a 256 -c checksums.txt 2>/dev/null | grep -q "${BINARY_NAME}.tar.gz: OK"; then
        log_success "Checksum verification passed"
    else
        log_warning "Checksum verification failed, but continuing installation"
    fi
fi

log_info "Extracting archive..."
tar -xzf "${BINARY_NAME}.tar.gz"

if [ ! -f "$BINARY_NAME" ]; then
    log_error "Binary not found in archive"
    exit 1
fi

# Make binary executable
chmod +x "$BINARY_NAME"

log_info "Testing binary..."
if ./"$BINARY_NAME" --version >/dev/null 2>&1; then
    log_success "Binary test passed"
else
    log_error "Binary test failed"
    exit 1
fi

# Check if we need sudo for installation
if [ -w "$INSTALL_DIR" ]; then
    SUDO=""
else
    SUDO="sudo"
    log_warning "Administrator privileges required for installation to $INSTALL_DIR"
fi

# Install binary
log_info "Installing $BINARY_NAME to $INSTALL_DIR..."
if $SUDO mv "$BINARY_NAME" "$INSTALL_DIR/"; then
    log_success "Installation completed successfully!"
else
    log_error "Installation failed"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

# Verify installation
log_info "Verifying installation..."
if command -v "$BINARY_NAME" >/dev/null 2>&1; then
    INSTALLED_VERSION=$("$BINARY_NAME" --version)
    log_success "$BINARY_NAME $INSTALLED_VERSION installed successfully!"
    
    echo ""
    log_info "Usage examples:"
    echo "  $BINARY_NAME --help"
    echo "  $BINARY_NAME create MyApp --organization-name 'My Company'"
    echo "  $BINARY_NAME list-targets MyApp.xcodeproj"
    
    echo ""
    log_info "For more information:"
    echo "  GitHub: https://github.com/$REPO"
    echo "  Documentation: https://github.com/$REPO#readme"
else
    log_error "Installation verification failed. $BINARY_NAME not found in PATH"
    log_info "Try adding $INSTALL_DIR to your PATH or restart your terminal"
    exit 1
fi