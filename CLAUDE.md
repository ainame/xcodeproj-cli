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

## Installation

### Via Homebrew (macOS/Linux)
```bash
brew install ainame/tap/xcodeproj
```

### Via npm (Cross-platform)
```bash
npm install -g @ainame/xcodeproj-cli
```

## Release Process

### To release a new version:
```bash
./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.3
```

This script will:
1. Validate version format and prerequisites
2. Update version in `Sources/xcodeproj-cli/Command.swift` and `package.json`
3. Build and test the project
4. Commit the version bump
5. Create and push a git tag
6. Trigger GitHub Actions to build and publish

### GitHub Actions automatically:
1. Builds universal binary (arm64 + x86_64) for macOS
2. Builds Linux binaries (x86_64 + aarch64)
3. Creates GitHub release with assets
4. Updates Homebrew formula with new URL and SHA256
5. Publishes to npm registry
6. Commits formula changes back to main

## npm Distribution

The project includes a complete npm distribution setup:

### Structure
```
xcodeproj-cli/
├── package.json          # npm package manifest (at root)
├── npm/                  # npm-specific files
│   ├── postinstall.js    # Downloads binary from GitHub releases
│   └── wrapper.js        # JavaScript entry point
└── .npmignore            # Excludes source code from npm package
```

### Components
- **package.json**: Defines npm package as `@ainame/xcodeproj-cli`
- **npm/wrapper.js**: JavaScript wrapper that detects platform/architecture
- **npm/postinstall.js**: Downloads appropriate binary from GitHub releases after npm install
- **.npmignore**: Excludes source code, only includes essential distribution files

### How it works
1. User runs `npm install -g @ainame/xcodeproj-cli`
2. npm installs the lightweight package (no binaries included)
3. Post-install script downloads the correct binary based on platform:
   - macOS (x64/arm64): `xcodeproj-macos-universal`
   - Linux x64: `xcodeproj-linux-x86_64`
   - Linux arm64: `xcodeproj-linux-aarch64`
4. Binary is verified via checksum and made executable
5. JavaScript wrapper (`npm/wrapper.js`) acts as entry point

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