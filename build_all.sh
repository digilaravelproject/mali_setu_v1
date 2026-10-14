#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "================================================"
echo "🚀 1/7: Deleting build directory & flutter clean..."
echo "================================================"
rm -rf build
flutter clean

echo "================================================"
echo "📦 2/7: Running flutter pub get..."
echo "================================================"
flutter pub get

echo "================================================"
echo "🍎 3/7: Deleting DerivedData, cleaning Pods & running pod install..."
echo "================================================"
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.podspec
cd ios && pod install --repo-update && cd ..

echo "================================================"
echo "🤖 4/7: Cleaning Android Gradle..."
echo "================================================"
cd android && ./gradlew clean && cd ..

echo "================================================"
echo "📱 5/7: Building Release APK..."
echo "================================================"
flutter build apk --release

echo "================================================"
echo "📦 6/7: Building Release App Bundle (AAB)..."
echo "================================================"
flutter build appbundle --release

echo "================================================"
echo "🍏 7/7: Building Release iOS App..."
echo "================================================"
flutter build ios --release

echo "================================================"
echo "✅ ALL BUILDS COMPLETED SUCCESSFULLY!"
echo "Outputs generated:"
echo "• APK: build/app/outputs/flutter-apk/app-release.apk"
echo "• AAB: build/app/outputs/bundle/release/app-release.aab"
echo "• iOS App: build/ios/iphoneos/Runner.app"
echo "================================================"
