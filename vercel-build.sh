#!/bin/bash
set -e

echo "=========================================="
echo "⚡ EV-MASTER Vercel Build Script ⚡"
echo "=========================================="

# Check if Flutter is already installed in environment or cached
if command -v flutter &> /dev/null; then
  echo "Flutter found in PATH: $(which flutter)"
else
  echo "Flutter not found. Installing Flutter SDK (stable channel)..."
  FLUTTER_CACHE_DIR="$HOME/flutter"
  
  if [ ! -d "$FLUTTER_CACHE_DIR" ]; then
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_CACHE_DIR"
  fi
  
  export PATH="$FLUTTER_CACHE_DIR/bin:$PATH"
fi

echo "Running flutter --version..."
flutter --version

echo "Disabling analytics & enabling web..."
flutter config --no-analytics
flutter config --enable-web

echo "Getting Flutter dependencies..."
flutter pub get

echo "Building web release..."
flutter build web --release

echo "=========================================="
echo "✅ Flutter Web build finished successfully!"
echo "Target directory: build/web"
echo "=========================================="
