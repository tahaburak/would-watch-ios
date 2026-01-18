#!/bin/bash

# Diagnostic script to check for common build issues
# This doesn't require Xcode to be installed

echo "🔍 Checking for common build issues..."
echo ""

cd "$(dirname "$0")"

ISSUES_FOUND=0

# Check 1: Deployment target
echo "1. Checking deployment targets..."
DEPLOYMENT_TARGET=$(grep -A 1 "IPHONEOS_DEPLOYMENT_TARGET" would_watch.xcodeproj/project.pbxproj | grep -o "[0-9]\+\.[0-9]\+" | head -1)
if [ ! -z "$DEPLOYMENT_TARGET" ]; then
    MAJOR_VERSION=$(echo "$DEPLOYMENT_TARGET" | cut -d. -f1)
    if [ "$MAJOR_VERSION" -gt 20 ]; then
        echo "   ⚠️  WARNING: IPHONEOS_DEPLOYMENT_TARGET is $DEPLOYMENT_TARGET (too high, should be 17.0 or 18.0)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo "   ✅ Deployment target: $DEPLOYMENT_TARGET"
    fi
fi

# Check 2: Missing imports
echo ""
echo "2. Checking for missing Combine imports in ViewModels..."
FILES_WITH_PUBLISHED=$(grep -l "@Published" would_watch/**/*.swift 2>/dev/null | grep -v ".swift~")
for file in $FILES_WITH_PUBLISHED; do
    if ! grep -q "import Combine" "$file"; then
        echo "   ⚠️  WARNING: $file uses @Published but doesn't import Combine"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "   ✅ All ViewModels have Combine imported"
fi

# Check 3: UIKit usage without imports
echo ""
echo "3. Checking for UIKit usage without imports..."
FILES_WITH_UIKIT=$(grep -l "UIColor\|UIApplication" would_watch/**/*.swift 2>/dev/null | grep -v ".swift~")
for file in $FILES_WITH_UIKIT; do
    if ! grep -q "import UIKit\|#if canImport(UIKit)" "$file"; then
        echo "   ⚠️  WARNING: $file uses UIKit types but may not import UIKit"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "   ✅ UIKit imports look correct"
fi

# Check 4: Missing type definitions
echo ""
echo "4. Checking for common type definitions..."
TYPES=("RoomMatch" "VoteType" "PrivacySetting" "RoomStatus" "NotificationType")
for type in "${TYPES[@]}"; do
    if ! grep -r "enum $type\|struct $type" would_watch/ --include="*.swift" > /dev/null 2>&1; then
        echo "   ⚠️  WARNING: Type '$type' not found"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "   ✅ All required types are defined"
fi

# Check 5: API client calls with missing headers
echo ""
echo "5. Checking API client calls..."
FILES_WITH_API_CALLS=$(grep -l "apiClient\.\(get\|post\|put\|delete\)" would_watch/**/*.swift 2>/dev/null | grep -v ".swift~")
MISSING_HEADERS=0
for file in $FILES_WITH_API_CALLS; do
    if grep -q "apiClient\.\(get\|post\|put\|delete\)([^,)]*)" "$file"; then
        echo "   ⚠️  WARNING: $file may have API calls missing headers parameter"
        MISSING_HEADERS=$((MISSING_HEADERS + 1))
    fi
done
if [ $MISSING_HEADERS -eq 0 ]; then
    echo "   ✅ All API calls include headers parameter"
else
    ISSUES_FOUND=$((ISSUES_FOUND + MISSING_HEADERS))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ No obvious issues found!"
    echo ""
    echo "💡 To actually build, you need:"
    echo "   1. Xcode installed"
    echo "   2. Run: xcodebuild -project would_watch.xcodeproj -scheme would_watch build"
else
    echo "⚠️  Found $ISSUES_FOUND potential issue(s)"
    echo ""
    echo "💡 Fix these issues and try building again"
fi
echo ""
