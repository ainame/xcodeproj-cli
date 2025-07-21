#!/usr/bin/env node

import { existsSync, mkdirSync, createWriteStream, chmodSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { pipeline } from 'stream/promises';
import { createHash } from 'crypto';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import https from 'https';

const __dirname = dirname(fileURLToPath(import.meta.url));

const REPO = 'ainame/xcodeproj-cli';
const VERSION = JSON.parse(readFileSync(join(__dirname, 'package.json'), 'utf8')).version;

// Binary mappings
const BINARY_MAPPINGS = {
  'darwin-x64': 'macos-universal',
  'darwin-arm64': 'macos-universal',
  'linux-x64': 'linux-x86_64',
  'linux-arm64': 'linux-aarch64'
};

async function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    console.log(`Downloading ${url}...`);
    
    https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Follow redirect
        downloadFile(response.headers.location, destPath).then(resolve).catch(reject);
        return;
      }
      
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download: ${response.statusCode}`));
        return;
      }
      
      const file = createWriteStream(destPath);
      response.pipe(file);
      
      file.on('finish', () => {
        file.close();
        resolve();
      });
      
      file.on('error', (err) => {
        file.close();
        reject(err);
      });
    }).on('error', reject);
  });
}

async function verifyChecksum(filePath, expectedChecksum) {
  const fileBuffer = readFileSync(filePath);
  const hash = createHash('sha256').update(fileBuffer).digest('hex');
  return hash === expectedChecksum;
}

async function downloadBinary() {
  const platform = process.platform;
  const arch = process.arch === 'x64' ? 'x64' : process.arch;
  
  const platformKey = `${platform}-${arch}`;
  const binaryVariant = BINARY_MAPPINGS[platformKey];
  
  if (!binaryVariant) {
    console.error(`Unsupported platform: ${platform} ${arch}`);
    process.exit(1);
  }
  
  const assetName = `xcodeproj-${VERSION}-${binaryVariant}.tar.gz`;
  
  // Create binaries directory
  const binariesDir = join(__dirname, 'binaries');
  if (!existsSync(binariesDir)) {
    mkdirSync(binariesDir, { recursive: true });
  }
  
  // Determine binary name for the platform
  let binaryName = 'xcodeproj';
  if (platform === 'darwin') {
    binaryName = 'xcodeproj-macos-universal';
  } else if (platform === 'linux') {
    binaryName = `xcodeproj-linux-${arch === 'x64' ? 'x86_64' : arch}`;
  }
  
  const binaryPath = join(binariesDir, binaryName);
  
  // Check if binary already exists
  if (existsSync(binaryPath)) {
    console.log('Binary already installed');
    return;
  }
  
  try {
    // Determine checksums file based on platform
    const checksumsFileName = platform === 'darwin' 
      ? `xcodeproj-${VERSION}-macos-checksums.txt`
      : `xcodeproj-${VERSION}-linux-checksums.txt`;
    
    // Download checksums
    const checksumsPath = join(binariesDir, checksumsFileName);
    if (!existsSync(checksumsPath)) {
      const checksumsUrl = `https://github.com/${REPO}/releases/download/${VERSION}/${checksumsFileName}`;
      await downloadFile(checksumsUrl, checksumsPath);
    }
    
    // Parse checksums
    const checksumsContent = readFileSync(checksumsPath, 'utf8');
    const checksums = {};
    checksumsContent.split('\n').forEach(line => {
      const parts = line.trim().split(/\s+/);
      if (parts.length >= 2) {
        const hash = parts[0];
        const filename = parts[parts.length - 1]; // Last part is filename
        if (hash && filename) {
          checksums[filename] = hash;
        }
      }
    });
    
    // Download binary archive
    const archivePath = join(binariesDir, assetName);
    const url = `https://github.com/${REPO}/releases/download/${VERSION}/${assetName}`;
    
    await downloadFile(url, archivePath);
    
    // Verify checksum
    const expectedChecksum = checksums[assetName];
    if (expectedChecksum) {
      console.log('Verifying checksum...');
      const isValid = await verifyChecksum(archivePath, expectedChecksum);
      if (!isValid) {
        throw new Error('Checksum verification failed');
      }
    }
    
    // Extract binary
    console.log('Extracting binary...');
    execSync(`tar -xzf "${archivePath}" -C "${binariesDir}"`, { stdio: 'inherit' });
    
    // Clean up archive
    execSync(`rm "${archivePath}"`, { stdio: 'inherit' });
    
    // Make binary executable
    chmodSync(binaryPath, 0o755);
    
    console.log('✓ xcodeproj-cli installed successfully');
    
  } catch (error) {
    console.error('Failed to install xcodeproj-cli:', error.message);
    console.error('You can manually download the binary from:');
    console.error(`https://github.com/${REPO}/releases/tag/${VERSION}`);
    process.exit(1);
  }
}

// Only run if this is a postinstall script
if (process.env.npm_lifecycle_event === 'postinstall') {
  downloadBinary().catch(console.error);
}