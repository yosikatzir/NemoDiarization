#!/bin/bash
# Script to create OFFLINE Windows deployment package (with pre-downloaded models)

PACKAGE_NAME="NemoDiarization_Windows10_Offline"
OUTPUT_ZIP="${PACKAGE_NAME}.zip"

echo "========================================================"
echo "Creating OFFLINE Windows 10 Deployment Package"
echo "========================================================"
echo

# Check if models folder exists
if [ ! -d "models" ]; then
    echo "ERROR: 'models' folder not found!"
    echo
    echo "You need to download the models first:"
    echo "  python download_models.py"
    echo
    echo "This will create a 'models' folder with required .nemo files"
    exit 1
fi

# Check for required models
echo "Checking for required models..."
required_models=(
    "models/vad_multilingual_marblenet.nemo"
    "models/titanet_large.nemo"
)

optional_models=(
    "models/stt_en_conformer_ctc_large.nemo"
)

missing_required=0
for model in "${required_models[@]}"; do
    if [ ! -f "$model" ]; then
        echo "  ✗ Missing required: $(basename $model)"
        missing_required=$((missing_required + 1))
    else
        size=$(du -h "$model" | cut -f1)
        echo "  ✓ Found: $(basename $model) ($size)"
    fi
done

for model in "${optional_models[@]}"; do
    if [ ! -f "$model" ]; then
        echo "  ⚠ Missing optional: $(basename $model) (can work without it)"
    else
        size=$(du -h "$model" | cut -f1)
        echo "  ✓ Found: $(basename $model) ($size)"
    fi
done

if [ $missing_required -gt 0 ]; then
    echo
    echo "ERROR: $missing_required required model(s) missing!"
    echo "Please run: python download_models.py"
    exit 1
fi

echo

# Core files to include
FILES=(
    "diarize_windows.py"
    "diar_infer_meeting.yaml"
    "diar_infer_meeting_offline.yaml"
    "requirements.txt"
    "install_windows.bat"
    "install_windows_offline.bat"
    "run_diarization.bat"
    "README_WINDOWS.md"
    "README_OFFLINE_SETUP.md"
    "QUICKSTART.txt"
    "download_models.py"
)

# Check if all files exist
echo "Checking core files..."
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
echo "Creating offline package with models..."

# Remove old package if exists
if [ -f "$OUTPUT_ZIP" ]; then
    rm "$OUTPUT_ZIP"
    echo "  Removed old package"
fi

# Create the zip file with both files and models folder
echo "  Packaging files..."
zip -q "$OUTPUT_ZIP" "${FILES[@]}"

echo "  Adding models folder..."
zip -qr "$OUTPUT_ZIP" models/

if [ $? -eq 0 ]; then
    size=$(du -h "$OUTPUT_ZIP" | cut -f1)
    echo
    echo "========================================================"
    echo "✓ OFFLINE Package created successfully!"
    echo "========================================================"
    echo "  File: $OUTPUT_ZIP"
    echo "  Size: $size"
    echo
    echo "This package contains:"
    echo
    echo "Core files:"
    for file in "${FILES[@]}"; do
        echo "  - $file"
    done
    echo
    echo "Pre-downloaded models:"
    for model in "${required_models[@]}" "${optional_models[@]}"; do
        if [ -f "$model" ]; then
            size=$(du -h "$model" | cut -f1)
            echo "  - $(basename $model) ($size)"
        fi
    done
    echo
    echo "========================================================"
    echo "Next steps for OFFLINE Windows 10 deployment:"
    echo "========================================================"
    echo "1. Transfer $OUTPUT_ZIP to your Windows 10 machine"
    echo "2. Extract the ZIP file"
    echo "3. Ensure Python 3.8+ is installed (transfer installer if needed)"
    echo "4. Ensure FFmpeg is installed (transfer if needed)"
    echo "5. Run: install_windows_offline.bat"
    echo "6. Use: run_diarization.bat your_audio.wav"
    echo
    echo "See README_OFFLINE_SETUP.md for detailed instructions"
    echo "========================================================"
    echo
else
    echo
    echo "Error: Failed to create package"
    exit 1
fi
