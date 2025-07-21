# xcodeproj CLI Project

This project implements a CLI tool to manipulate Xcode project files (.xcodeproj) by porting functionality from the xcodeproj-mcp-server.

## Project Structure
- Package name: `xcodeproj-cli` (was `xcodeproj_cli`, renamed to avoid module conflicts)
- Executable name: `xcodeproj`
- Target directory: `Sources/xcodeproj-cli/`
- Dependencies:
  - https://github.com/tuist/xcodeproj v9.4.3+ (for .xcodeproj manipulation)
  - https://github.com/apple/swift-argument-parser v1.6.1+ (for CLI structure)

## Commands Implemented
All 19 tools from the MCP server have been converted to CLI subcommands:
- ✅ create (from create_xcodeproj)
- ✅ list-targets
- ✅ list-build-configurations
- ✅ list-files
- ✅ get-build-settings
- ✅ add-file
- ✅ remove-file
- ✅ move-file
- ✅ create-group
- ✅ add-target
- ✅ remove-target
- ✅ add-dependency
- ✅ set-build-setting
- ✅ add-framework
- ✅ add-build-phase
- ✅ duplicate-target
- ✅ add-swift-package
- ✅ list-swift-packages
- ✅ remove-swift-package

## Release Process

### To release a new version:
```bash
./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.3
```

This script will:
1. Validate version format and prerequisites
2. Update version in `Sources/xcodeproj-cli/Command.swift`
3. Build and test the project
4. Commit the version bump
5. Create and push a git tag
6. Trigger GitHub Actions to build and publish

### GitHub Actions automatically:
1. Builds universal binary (arm64 + x86_64)
2. Creates GitHub release with assets
3. Updates Homebrew formula with new URL and SHA256
4. Commits formula changes back to main

## Development Guidelines
- Use ./tmp as workspace (gitignored)
- Scripts are tracked in ./scripts (no longer gitignored)
- Follow the MCP server's implementation patterns but adapt for CLI context
- Use proper error handling and exit codes
- Provide helpful command descriptions and examples

## Building
```bash
# Development build
swift build

# Release build
swift build -c release

# Run directly
swift run xcodeproj --help
```

## Testing

### macOS Testing
```bash
# Run local macOS tests
./scripts/test.sh
```

### Linux Compatibility Testing  
```bash
# Run Linux tests (native on Linux, Docker on macOS)
./scripts/test-linux-native.sh  # For native Linux environments
./scripts/test-linux.sh         # For Docker-based testing

# Run comprehensive testing (macOS + Linux with auto-detection)
./scripts/test-all.sh

# Skip Linux tests if needed
./scripts/test-all.sh --skip-linux
```

### Manual Testing
```bash
# Test individual commands
./TestDemo.xcodeproj
xcodeproj list-targets TestDemo.xcodeproj
```

## Important Notes
- Version in Command.swift must match git tag for releases
- BuildSetting type in XcodeProj 9.x uses enum (.string/.array) instead of direct values
- Homebrew formula is automatically updated by GitHub Actions after release
- Use Renovate for automated dependency updates (configured in .github/renovate.json)