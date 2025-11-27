# Offline Installation Guide for Windows 10

This guide explains how to set up NeMo Diarization on a Windows 10 machine **WITHOUT internet access**.

## Overview

Since your Windows 10 machine doesn't have internet access, we need a **two-step process**:

1. **Download models** on a machine with internet (your Mac, another Windows PC, or Linux)
2. **Transfer complete package** to your offline Windows 10 machine

---

## Step 1: Download Models (On Internet-Connected Machine)

### Option A: Using Your Mac (Recommended)

1. **Install NeMo on your Mac** (if not already installed):
   ```bash
   pip install nemo_toolkit[asr]
   ```

2. **Run the model download script**:
   ```bash
   cd /path/to/NemoDiarization
   python download_models.py
   ```

3. **Wait for downloads to complete** (~690 MB total):
   - VAD Model: ~90 MB
   - Speaker Embedding (TitaNet): ~100 MB
   - ASR Model: ~500 MB
   - Download time: 5-15 minutes

4. **Verify models were downloaded**:
   ```bash
   ls -lh models/
   ```
   You should see:
   - `vad_multilingual_marblenet.nemo`
   - `titanet_large.nemo`
   - `stt_en_conformer_ctc_large.nemo`

### Option B: Using Another Windows PC with Internet

1. **Transfer the NemoDiarization folder** to a Windows PC with internet

2. **Install Python 3.8+** (if not installed)

3. **Install NeMo**:
   ```
   pip install nemo_toolkit[asr]
   ```

4. **Run the download script**:
   ```
   python download_models.py
   ```

5. **Wait for completion** and verify the `models` folder contains the .nemo files

---

## Step 2: Create Complete Offline Package

After downloading the models, you need to create a complete package that includes both the code and the pre-downloaded models.

### On Mac/Linux:

```bash
# Run the updated packaging script
./create_windows_package_offline.sh
```

This creates: `NemoDiarization_Windows10_Offline.zip` (~700 MB)

### On Windows:

```batch
create_windows_package_offline.bat
```

This creates: `NemoDiarization_Windows10_Offline.zip` (~700 MB)

---

## Step 3: Transfer to Offline Windows 10 Machine

1. **Copy the ZIP file** to a USB drive, network share, or other transfer method

2. **Transfer to your offline Windows 10 machine**

3. **Extract** to a folder (e.g., `C:\NemoDiarization`)

---

## Step 4: Install on Offline Windows 10

### Prerequisites (Must be installed first):

#### 1. Python 3.8 or Higher

You need to install Python on the offline machine. Two options:

**Option A: Transfer Python Installer**
- Download Python installer on internet-connected machine from: https://www.python.org/downloads/
- Get the Windows installer (.exe file)
- Transfer to offline machine and install
- **IMPORTANT**: Check "Add Python to PATH" during installation

**Option B: Use Embedded Python**
- Download "Windows embeddable package" from Python downloads
- Extract and configure manually (advanced)

#### 2. FFmpeg (For MP3/MP4/M4A Support)

**Option A: Transfer FFmpeg**
- On internet-connected machine, download from: https://www.gyan.dev/ffmpeg/builds/
- Download "ffmpeg-release-essentials.zip"
- Transfer the ZIP to offline machine
- Extract and add to system PATH or copy `ffmpeg.exe` to NemoDiarization folder

**Option B: WAV Only**
- Skip FFmpeg if you only use WAV files
- You won't be able to process MP3/MP4/M4A files

### Installation Steps:

1. **Open Command Prompt** in the extracted folder

2. **Verify Python is installed**:
   ```
   python --version
   ```
   Should show Python 3.8 or higher

3. **Run the offline installation**:
   ```
   install_windows_offline.bat
   ```

   This will:
   - Create a Python virtual environment
   - Install PyTorch (from wheel files if included, or requires internet)
   - Install NeMo and dependencies
   - Configure to use local models

4. **Wait for installation** (5-10 minutes)

---

## Step 5: Using the Offline System

Once installed, usage is identical to the online version:

```batch
run_diarization.bat your_audio.wav
```

The system will automatically:
- Detect the `models` folder exists
- Use `diar_infer_meeting_offline.yaml` configuration
- Load models from local files instead of downloading

### Supported Formats:
- `.wav` (recommended, fastest)
- `.mp3` (requires FFmpeg)
- `.mp4` (requires FFmpeg)
- `.m4a` (requires FFmpeg)

---

## Troubleshooting Offline Installation

### "Python is not installed"
- Ensure Python was transferred and installed
- Check that Python is in system PATH
- Restart Command Prompt after installing Python

### "ERROR: Could not find a version that satisfies the requirement..."
This means pip is trying to download packages from the internet.

**Solutions:**

1. **Create a pip cache** on internet-connected machine:
   ```bash
   # On internet-connected machine
   pip download -r requirements.txt -d pip_packages
   ```

   Then transfer the `pip_packages` folder and install:
   ```batch
   # On offline machine
   pip install --no-index --find-links=pip_packages -r requirements.txt
   ```

2. **Use pre-built wheel files** (advanced):
   - Download all wheel files on internet machine
   - Transfer to offline machine
   - Install from local wheels

### "FFmpeg not found" errors
- Install FFmpeg (see prerequisites)
- OR only use WAV files (no conversion needed)

### Models not found
- Verify the `models` folder exists
- Check it contains all three .nemo files
- Ensure you're using `diar_infer_meeting_offline.yaml`

---

## What's Different in Offline Mode?

### Online Mode (Original):
- Downloads models from NVIDIA NGC on first run
- Requires internet connection
- Uses `diar_infer_meeting.yaml`
- Model paths: `vad_multilingual_marblenet` (name, not path)

### Offline Mode (This Guide):
- Uses pre-downloaded local models
- No internet required after setup
- Uses `diar_infer_meeting_offline.yaml`
- Model paths: `models/vad_multilingual_marblenet.nemo` (local files)

---

## Advanced: Fully Offline Package with Dependencies

For a completely self-contained offline installation, you can pre-download all Python packages:

### On Internet-Connected Machine:

```bash
# Download all Python packages
pip download -r requirements.txt -d pip_packages

# Download PyTorch separately (large files)
pip download torch torchaudio --index-url https://download.pytorch.org/whl/cpu -d pip_packages
```

### Create custom installation script:

```batch
@echo off
echo Installing from local packages...
python -m venv venv
call venv\Scripts\activate
pip install --no-index --find-links=pip_packages -r requirements.txt
echo Installation complete!
pause
```

### Package structure:
```
NemoDiarization/
├── models/                    # Pre-downloaded .nemo models (~700 MB)
├── pip_packages/              # Pre-downloaded Python packages (~2 GB)
├── diarize_windows.py
├── diar_infer_meeting_offline.yaml
├── requirements.txt
├── install_windows_offline.bat
├── run_diarization.bat
└── README_OFFLINE_SETUP.md
```

This creates a fully self-contained package (~3 GB) that requires **zero internet access**.

---

## File Size Summary

| Component | Size | Required |
|-----------|------|----------|
| Code files | ~50 KB | Yes |
| Pre-downloaded models | ~700 MB | Yes (offline) |
| Python packages (optional) | ~2-3 GB | No* |
| Total (minimal) | ~700 MB | |
| Total (fully offline) | ~3-4 GB | |

*Python packages can be downloaded during installation if offline machine has Python and pip configured

---

## Questions?

- If models are missing: Re-run `download_models.py` on internet machine
- If packages won't install: Create pip cache (see advanced section)
- For testing: Try with a small WAV file first

---

## Summary Checklist

- [ ] Download models using `download_models.py` on internet machine
- [ ] Verify `models` folder contains 3 .nemo files
- [ ] Create offline package ZIP
- [ ] Transfer Python installer to offline machine
- [ ] Transfer FFmpeg to offline machine (if needed)
- [ ] Transfer package ZIP to offline machine
- [ ] Install Python on offline machine (add to PATH!)
- [ ] Install FFmpeg on offline machine (add to PATH!)
- [ ] Extract package ZIP
- [ ] Run `install_windows_offline.bat`
- [ ] Test with `run_diarization.bat test.wav`

Once setup is complete, you can diarize audio files offline with the same simple command:
```batch
run_diarization.bat your_audio_file.wav
```
