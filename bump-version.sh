#!/bin/bash

# Version bump script for SnapPass
# Use this in your PR branch before merging to master
# Usage: ./bump-version.sh <version>
# Example: ./bump-version.sh 2.0.0

set -e

if [ -z "$1" ]; then
    echo "Error: Version number required"
    echo "Usage: ./bump-version.sh <version>"
    echo "Example: ./bump-version.sh 2.0.0"
    exit 1
fi

VERSION="$1"

echo "================================================"
echo "SnapPass Version Bump"
echo "================================================"
echo "New Version: ${VERSION}"
echo ""

# Update version in all files
echo "Updating version numbers in project files..."

# Update setup.py
sed -i.bak "s/version='[^']*'/version='${VERSION}'/" setup.py && rm setup.py.bak

# Update setup.cfg
sed -i.bak "s/current_version = .*/current_version = ${VERSION}/" setup.cfg && rm setup.cfg.bak

# Update snappass/__init__.py
sed -i.bak "s/__version__ = '[^']*'/__version__ = '${VERSION}'/" snappass/__init__.py && rm snappass/__init__.py.bak

echo "✓ Updated versions in:"
echo "  - setup.py"
echo "  - setup.cfg"
echo "  - snappass/__init__.py"
echo ""

# Show the changes
echo "Changes made:"
git diff setup.py setup.cfg snappass/__init__.py

echo ""
echo "================================================"
echo "✓ Version bumped to ${VERSION}"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Review the changes above"
echo "  2. git add setup.py setup.cfg snappass/__init__.py"
echo "  3. git commit -m 'Bump version to ${VERSION}'"
echo "  4. Create/update PR to merge to master"
echo "  5. After merge, run: ./release.sh ${VERSION}"
echo ""

