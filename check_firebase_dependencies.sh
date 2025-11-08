#!/bin/bash

echo "🔍 Checking Firebase Dependencies in Xcode Project..."

# Check if Firebase package is referenced
if grep -q "firebase-ios-sdk" 8803NourishFit.xcodeproj/project.pbxproj; then
    echo "✅ Firebase iOS SDK package is referenced"
else
    echo "❌ Firebase iOS SDK package is NOT referenced"
fi

# Check if individual packages are linked to target
if grep -q "FirebaseAuth" 8803NourishFit.xcodeproj/project.pbxproj; then
    echo "✅ FirebaseAuth is linked"
else
    echo "❌ FirebaseAuth is NOT linked"
fi

if grep -q "FirebaseCore" 8803NourishFit.xcodeproj/project.pbxproj; then
    echo "✅ FirebaseCore is linked"
else
    echo "❌ FirebaseCore is NOT linked"
fi

if grep -q "FirebaseFirestore" 8803NourishFit.xcodeproj/project.pbxproj; then
    echo "✅ FirebaseFirestore is linked"
else
    echo "❌ FirebaseFirestore is NOT linked"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Open Xcode"
echo "2. Select your project → Target → General tab"
echo "3. Add Firebase packages to 'Frameworks, Libraries, and Embedded Content'"
echo "4. Clean Build Folder (Cmd+Shift+K)"
echo "5. Build (Cmd+B)"
