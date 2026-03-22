#!/bin/bash
set -e

PACKAGE="${1:?Usage: install.sh <package-name>}"
REPO="lepijohnny/sparky-extractors"
BRANCH="main"
DEST="$HOME/.sparky/plugins/ext"

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
npm install "$SRCDIR" --prefix "$DEST" --install-links

echo "Done. Restart Sparky to load $PACKAGE."
