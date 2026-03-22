#!/bin/bash
set -e

PACKAGE="${1:?Usage: install.sh <package-name>}"
REPO="lepijohnny/sparky-extractors"
BRANCH="main"
DEST="$HOME/.sparky/plugins/ext/node_modules/$PACKAGE"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading $PACKAGE..."
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMPDIR"

SRCDIR="$TMPDIR/sparky-extractors-$BRANCH/packages/$PACKAGE"
if [ ! -d "$SRCDIR" ]; then
  echo "Error: package '$PACKAGE' not found in repo"
  echo "Available: $(ls "$TMPDIR/sparky-extractors-$BRANCH/packages/")"
  exit 1
fi

echo "Installing to $DEST..."
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRCDIR"/* "$DEST"/
(cd "$DEST" && npm install --omit=dev 2>&1)

echo "Done. Restart Sparky to load $PACKAGE."
