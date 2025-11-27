#!/bin/bash
# Script to create Windows deployment package

PACKAGE_NAME="NemoDiarization_Windows10"
OUTPUT_ZIP="${PACKAGE_NAME}.zip"

echo "================================================"
echo "Creating Windows 10 Deployment Package"
echo "================================================"
echo

# Files to include in the package
FILES=(
    "diarize_windows.py"
    "diar_infer_meeting.yaml"
    "diar_infer_meeting_offline.yaml"
    "requirements.txt"
    "install_windows.bat"
    "install_windows_offline.bat"
    "run_diarization.bat"
    "download_models.py"
    "README_WINDOWS.md"
    "README_OFFLINE_SETUP.md"
    "QUICKSTART.txt"
)

# Check if all files exist
echo "Checking files..."
missing_files=0
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "  ✗ Missing: $file"
        missing_files=$((missing_files + 1))
    else
        echo "  ✓ Found: $file"
    fi
done

if [ $missing_files -gt 0 ]; then
    echo
    echo "Error: $missing_files file(s) missing. Cannot create package."
    exit 1
fi

echo
echo "Creating zip package..."

# Remove old package if exists
if [ -f "$OUTPUT_ZIP" ]; then
    rm "$OUTPUT_ZIP"
    echo "  Removed old package"
fi

# Create the zip file
zip -q "$OUTPUT_ZIP" "${FILES[@]}"

if [ $? -eq 0 ]; then
    size=$(du -h "$OUTPUT_ZIP" | cut -f1)
    echo
    echo "================================================"
    echo "✓ Package created successfully!"
    echo "================================================"
    echo "  File: $OUTPUT_ZIP"
    echo "  Size: $size"
    echo
    echo "This package contains:"
    for file in "${FILES[@]}"; do
        echo "  - $file"
    done
    echo
    echo "Next steps:"
    echo "1. Transfer $OUTPUT_ZIP to your Windows 10 machine"
    echo "2. Extract the ZIP file"
    echo "3. Follow instructions in QUICKSTART.txt"
    echo
else
    echo
    echo "Error: Failed to create package"
    exit 1
fi
