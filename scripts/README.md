# Automation Scripts

This folder contains all automation and utility scripts for the project.

## Purpose

These scripts include:
- Build and deployment scripts
- Setup and configuration scripts
- Testing and verification scripts
- Development workflow scripts

## Usage

Scripts can be run from the project root or from within this directory:

```powershell
# From project root
.\scripts\SCRIPT_NAME.ps1

# Or navigate to scripts folder
cd scripts
.\SCRIPT_NAME.ps1
```

## Script Categories

### Build Scripts
- `BUILD_AAB.ps1` - Build Android App Bundle
- `BUILD_AAB_RELEASE.ps1` - Build release AAB
- `SETUP_RELEASE_SIGNING.ps1` - Setup release signing

### Setup Scripts
- `CREATE_KEYSTORE_SIMPLE.ps1` - Create keystore
- `CREATE_RELEASE_KEYSTORE.ps1` - Create release keystore
- `SETUP_POSTGRES.ps1` - Setup PostgreSQL database
- `CREATE_FIREBASE_INDEXES.ps1` - Create Firebase indexes

### Development Scripts
- `RUN_BOTH.ps1` - Run both backend and mobile
- `run-backend.ps1` - Run backend only
- `run-mobile.ps1` - Run mobile only
- `START_BACKEND.ps1` - Start backend server

### Testing Scripts
- `QUICK_TEST.ps1` - Quick test script
- `TEST_CONNECTION.ps1` - Test connection
- `VERIFY_CONNECTION.ps1` - Verify connection

### Utility Scripts
- `FIND_IP.ps1` - Find IP address
- `ALLOW_FIREWALL.ps1` - Allow firewall rules
- `REINSTALL_APP.ps1` - Reinstall app

## Note

Some npm/node_modules wrapper scripts may also be present in this folder. These are typically generated automatically and can be ignored for manual execution.

