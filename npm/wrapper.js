#!/usr/bin/env node

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Determine platform and architecture
const platform = process.platform;
const arch = process.arch === 'x64' ? 'x86_64' : process.arch;

// Map to binary path
let binaryName = 'xcodeproj';
if (platform === 'darwin') {
  binaryName = 'xcodeproj-macos-universal';
} else if (platform === 'linux') {
  binaryName = `xcodeproj-linux-${arch}`;
} else {
  console.error(`Unsupported platform: ${platform}`);
  process.exit(1);
}

const binaryPath = join(__dirname, '..', 'binaries', binaryName);

if (!existsSync(binaryPath)) {
  console.error(`Error: xcodeproj binary not found at ${binaryPath}`);
  console.error('Please reinstall the package: npm install @ainame/xcodeproj-cli');
  process.exit(1);
}

// Spawn the binary with all arguments
const child = spawn(binaryPath, process.argv.slice(2), { 
  stdio: 'inherit',
  env: process.env
});

child.on('error', (error) => {
  console.error(`Failed to execute xcodeproj: ${error.message}`);
  process.exit(1);
});

child.on('exit', (code) => {
  process.exit(code || 0);
});