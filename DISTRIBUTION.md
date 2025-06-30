# Distribution Strategy for xcodeproj CLI

This document outlines the comprehensive distribution strategy for xcodeproj CLI, including automated builds, package management, and installation methods.

## Overview

The distribution strategy focuses on:
1. **Automated releases** via GitHub Actions
2. **Multiple installation methods** for different user preferences
3. **Universal binary support** (Apple Silicon + Intel)
4. **Package manager integration** (Homebrew)
5. **Security and verification** with checksums

## 1. GitHub Actions Automated Releases

### Release Workflow (`.github/workflows/release.yml`)

**Triggers:**
- Git tags matching `v*` (e.g., `v0.0.2`, `v1.0.0`)
- Manual dispatch with version input

**Process:**
1. Builds universal binary (arm64 + x86_64)
2. Creates compressed archive
3. Generates SHA256 checksums
4. Tests binary functionality
5. Creates GitHub release with assets
6. Uploads binary, archive, and checksums

**Assets produced:**
- `xcodeproj` - Raw universal binary
- `xcodeproj-v0.0.1-macos-universal.tar.gz` - Compressed archive
- `xcodeproj-v0.0.1-checksums.txt` - SHA256 checksums

### CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to main/develop branches
- Pull requests to main

**Process:**
1. Builds debug and release versions
2. Runs comprehensive test suite (`test_xcodeproj_cli.sh`)
3. Performs basic functionality tests
4. Optional Swift format checking

## 2. Installation Methods

### Method 1: Direct Download (Recommended)

```bash
# Download and install latest version
curl -sSL https://raw.githubusercontent.com/ainame/xcodeproj_cli/main/install.sh | bash
```

**Features:**
- Automatic latest version detection
- Checksum verification
- Universal binary support
- Installation to `/usr/local/bin`
- Post-install verification

### Method 2: Manual Download

```bash
# Download specific version
VERSION="v0.0.1"
curl -L -o xcodeproj.tar.gz "https://github.com/ainame/xcodeproj_cli/releases/download/$VERSION/xcodeproj-$VERSION-macos-universal.tar.gz"

# Extract and install
tar -xzf xcodeproj.tar.gz
chmod +x xcodeproj
sudo mv xcodeproj /usr/local/bin/
```

### Method 3: Homebrew (Planned)

```bash
# Add custom tap
brew tap ainame/tap

# Install xcodeproj
brew install xcodeproj
```

**Homebrew Formula Features:**
- Automatic dependency management
- Build from source
- Integration with Homebrew ecosystem
- Easy updates via `brew upgrade`

### Method 4: Build from Source

```bash
# Clone repository
git clone https://github.com/ainame/xcodeproj_cli.git
cd xcodeproj_cli

# Build release binary
swift build -c release

# Install
cp .build/release/xcodeproj /usr/local/bin/
```

## 3. Release Process

### Automated Release (Recommended)

1. **Create and push tag:**
   ```bash
   git tag v0.0.2
   git push origin v0.0.2
   ```

2. **GitHub Actions automatically:**
   - Builds universal binary
   - Creates release
   - Uploads assets
   - Updates documentation

### Manual Release

1. **Manual trigger via GitHub UI:**
   - Go to Actions → Release workflow
   - Click "Run workflow"
   - Enter version (e.g., `v0.0.2`)

## 4. Binary Distribution Details

### Universal Binary Support

- **Apple Silicon (arm64):** Native performance on M1/M2 Macs
- **Intel (x86_64):** Compatible with older Macs
- **Universal Binary:** Single file works on both architectures

### Verification and Security

- **SHA256 checksums** for all releases
- **Binary testing** before release
- **Automated verification** in install script
- **GitHub-signed releases** via Actions

### File Structure

```
Release Assets:
├── xcodeproj                                    # Raw universal binary
├── xcodeproj-v0.0.1-macos-universal.tar.gz    # Compressed archive
└── xcodeproj-v0.0.1-checksums.txt             # SHA256 checksums
```

## 5. Package Manager Integration

### Homebrew Formula

Location: `Formula/xcodeproj.rb`

**Features:**
- Source-based installation
- Automatic Xcode dependency detection
- Integration with Homebrew testing
- Support for HEAD installs (latest main branch)

**Submission Process:**
1. Test formula locally
2. Submit to homebrew-core or create custom tap
3. Update documentation with Homebrew instructions

### Future Package Managers

**Potential integrations:**
- **MacPorts:** For alternative macOS package management
- **Nix:** For reproducible builds
- **Swift Package Registry:** When available for executables

## 6. Distribution Channels

### Primary Channels

1. **GitHub Releases** - Main distribution point
2. **Install Script** - Automated installation
3. **Homebrew** - Package manager integration
4. **Documentation** - README installation instructions

### Secondary Channels

1. **Developer Communities** - Swift forums, Reddit
2. **Documentation Sites** - Integration with Swift documentation
3. **CI/CD Examples** - GitHub Actions marketplace

## 7. Version Management

### Semantic Versioning

- **v0.x.x** - Pre-release versions (current)
- **v1.0.0** - First stable release
- **vX.Y.Z** - Standard semantic versioning

### Release Notes

Each release includes:
- Feature additions/changes
- Bug fixes
- Breaking changes (if any)
- Installation instructions
- Checksums for verification

## 8. Monitoring and Analytics

### GitHub Insights

- **Download statistics** from GitHub releases
- **Repository traffic** and clone metrics
- **Issue tracking** for user feedback

### User Feedback Channels

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Community support
- **Documentation** - Usage examples and guides

## 9. Maintenance Strategy

### Automated Maintenance

- **CI/CD pipelines** ensure quality
- **Dependency updates** via automated PRs
- **Security scanning** in GitHub Actions

### Manual Maintenance

- **Release planning** based on user feedback
- **Documentation updates** for new features
- **Community engagement** and support

## 10. Future Enhancements

### Planned Improvements

1. **Code signing** for enhanced security
2. **Notarization** for macOS Gatekeeper
3. **Multi-platform support** (if applicable)
4. **Package manager submissions** to official repos
5. **Auto-updater** functionality in CLI

### Distribution Metrics

- Track download counts per release
- Monitor installation method popularity
- Gather user feedback on installation experience
- Optimize based on usage patterns

---

This distribution strategy ensures xcodeproj CLI reaches users through multiple channels while maintaining security, reliability, and ease of installation.