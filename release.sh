#!/bin/bash

# Release script for SnapPass
# Use this on master branch AFTER merging your PR with version bump
# Usage: ./release.sh <version>
# Example: ./release.sh 2.0.0

set -e

if [ -z "$1" ]; then
    echo "Error: Version number required"
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh 2.0.0"
    exit 1
fi

VERSION="$1"
TAG="v${VERSION}"

echo "================================================"
echo "SnapPass Release Script"
echo "================================================"
echo "Version: ${VERSION}"
echo "Tag: ${TAG}"
echo ""

# Verify we're on master
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "master" ] && [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Warning: You are on branch '${CURRENT_BRANCH}', not 'master'"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: Tag ${TAG} already exists"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes"
    echo "Please commit or stash them before creating a release"
    exit 1
fi

# Verify version matches what's in the files
SETUP_VERSION=$(grep "version=" setup.py | sed "s/.*version='\([^']*\)'.*/\1/")
INIT_VERSION=$(grep "__version__" snappass/__init__.py | sed "s/.*__version__ = '\([^']*\)'.*/\1/")

if [ "$SETUP_VERSION" != "$VERSION" ]; then
    echo "Warning: setup.py has version '${SETUP_VERSION}' but you specified '${VERSION}'"
    echo "Run ./bump-version.sh ${VERSION} first in your PR branch before merging"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

if [ "$INIT_VERSION" != "$VERSION" ]; then
    echo "Warning: snappass/__init__.py has version '${INIT_VERSION}' but you specified '${VERSION}'"
    echo "Run ./bump-version.sh ${VERSION} first in your PR branch before merging"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

echo "✓ Version ${VERSION} confirmed in project files"
echo ""

# Create and push tag
echo "Creating tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${VERSION}"

echo "Pushing tag to origin..."
git push origin "${TAG}"

echo ""
echo "================================================"
echo "✓ Release ${VERSION} tagged and pushed!"
echo "================================================"
echo ""
echo "GitHub Actions will now:"
echo "  1. Run tests on Python 3.9-3.13"
echo "  2. Build Docker image"
echo "  3. Push to Docker Hub: rjpr/snappass:${VERSION}"
echo "  4. Push to GitHub CR: ghcr.io/rjpr/snappass:${VERSION}"
echo ""
echo "Monitor progress at:"
echo "  https://github.com/rjpr/snappass/actions"
echo ""
echo "Once complete, verify images at:"
echo "  - https://hub.docker.com/r/rjpr/snappass"
echo "  - https://github.com/rjpr/snappass/pkgs/container/snappass"
echo ""
