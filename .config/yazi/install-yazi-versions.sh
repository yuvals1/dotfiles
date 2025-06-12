#!/bin/bash

# Script to install multiple versions of yazi between v25.2.26 and v25.5.31

# Define the versions to install (in order)
VERSIONS=(
    "25.3.2"
    "25.4.8"
    "25.5.28"
    "25.5.31"
)

# Base directory for all yazi versions
YAZI_BASE="$HOME/.local/yazi-versions"

# Create base directory
mkdir -p "$YAZI_BASE"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing multiple yazi versions...${NC}"
echo "Base directory: $YAZI_BASE"
echo ""

# Function to install a specific version
install_yazi_version() {
    local version=$1
    local version_dir="$YAZI_BASE/v$version"
    
    echo -e "${BLUE}Installing yazi v$version...${NC}"
    
    # Skip if already installed
    if [ -f "$version_dir/yazi" ]; then
        echo -e "${GREEN}✓ v$version already installed${NC}"
        return 0
    fi
    
    # Create version directory
    mkdir -p "$version_dir"
    
    # Download the release
    local download_url="https://github.com/sxyazi/yazi/releases/download/v$version/yazi-x86_64-apple-darwin.zip"
    local temp_file="/tmp/yazi-v$version.zip"
    
    echo "  Downloading from: $download_url"
    if curl -L "$download_url" -o "$temp_file" --silent --fail; then
        # Extract to temp directory
        local temp_extract="/tmp/yazi-extract-$version"
        rm -rf "$temp_extract"
        unzip -q "$temp_file" -d "$temp_extract"
        
        # Copy binaries to version directory
        cp "$temp_extract/yazi-x86_64-apple-darwin/yazi" "$version_dir/"
        cp "$temp_extract/yazi-x86_64-apple-darwin/ya" "$version_dir/"
        
        # Make executable
        chmod +x "$version_dir/yazi" "$version_dir/ya"
        
        # Clean up
        rm -f "$temp_file"
        rm -rf "$temp_extract"
        
        echo -e "${GREEN}✓ Successfully installed v$version${NC}"
    else
        echo -e "${RED}✗ Failed to download v$version${NC}"
        return 1
    fi
}

# Install all versions
for version in "${VERSIONS[@]}"; do
    install_yazi_version "$version"
    echo ""
done

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "All versions installed in: $YAZI_BASE"
echo ""
echo "To test a specific version:"
echo "  $YAZI_BASE/v25.3.2/yazi --version"
echo "  $YAZI_BASE/v25.4.8/yazi --version"
echo "  $YAZI_BASE/v25.5.28/yazi --version"
echo "  $YAZI_BASE/v25.5.31/yazi --version"
echo ""
echo "To find which version introduced the bug, try running each one:"
echo "  for v in $YAZI_BASE/v*/; do echo \"Testing \$v\"; \"\$v/yazi\" 2>&1 | head -5; echo; done"
