#!/bin/bash
echo "🔥 Building Thiral Release..."
flutter clean
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter build appbundle --release \
  --dart-define=GEMINI_KEY=$GEMINI_KEY \
  --obfuscate \
  --split-debug-info=build/debug-info
echo "✅ Build complete: build/app/outputs/bundle/release/app-release.aab"
