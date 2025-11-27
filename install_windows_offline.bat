@echo off
echo ============================================
echo NeMo Diarization - OFFLINE Windows Setup
echo ============================================
echo.

REM Check if models folder exists
if not exist "models\" (
    echo ERROR: Models folder not found!
    echo.
    echo This is the OFFLINE installer. You need to download models first.
    echo.
    echo Please follow these steps:
    echo 1. On a machine with internet, run: python download_models.py
    echo 2. Copy the 'models' folder to this directory
    echo 3. Run this installer again
    echo.
    echo See README_OFFLINE_SETUP.md for detailed instructions.
    pause
    exit /b 1
)

echo Checking for required models...
set missing_models=0

if not exist "models\vad_multilingual_marblenet.nemo" (
    echo   [X] Missing: vad_multilingual_marblenet.nemo
    set /a missing_models+=1
) else (
    echo   [OK] Found: vad_multilingual_marblenet.nemo
)

if not exist "models\titanet_large.nemo" (
    echo   [X] Missing: titanet_large.nemo
    set /a missing_models+=1
) else (
    echo   [OK] Found: titanet_large.nemo
)

if not exist "models\stt_en_conformer_ctc_large.nemo" (
    echo   [!] Optional: stt_en_conformer_ctc_large.nemo not found
    echo       (ASR model - can work without it)
) else (
    echo   [OK] Found: stt_en_conformer_ctc_large.nemo
)

if %missing_models% gtr 0 (
    echo.
    echo ERROR: %missing_models% required model(s) missing!
    echo Please download models using download_models.py on an internet-connected machine.
    pause
    exit /b 1
)

echo.
echo All required models found!
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python 3.8 or higher
    echo Transfer the Python installer to this machine and install it
    echo.
    echo IMPORTANT: Check "Add Python to PATH" during installation!
    pause
    exit /b 1
)

echo Python found:
python --version
echo.

REM Check Python version
python -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python 3.8 or higher is required
    pause
    exit /b 1
)

echo Creating virtual environment...
python -m venv venv
if errorlevel 1 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

echo.
echo Activating virtual environment...
call venv\Scripts\activate.bat

echo.
echo Upgrading pip...
python -m pip install --upgrade pip --no-index --find-links pip_packages 2>nul
if errorlevel 1 (
    echo Note: Attempting to upgrade pip from internet (offline packages not found)
    python -m pip install --upgrade pip
)

echo.
echo Checking for offline package cache...
if exist "pip_packages\" (
    echo Found offline package cache! Installing from local files...
    echo.
    echo Installing PyTorch from local files...
    pip install --no-index --find-links=pip_packages torch torchaudio

    echo.
    echo Installing NeMo and dependencies from local files...
    pip install --no-index --find-links=pip_packages -r requirements.txt
) else (
    echo No offline package cache found.
    echo.
    echo IMPORTANT: This machine needs internet to download Python packages!
    echo.
    echo If this machine is offline, please:
    echo 1. On internet-connected machine, run:
    echo    pip download -r requirements.txt -d pip_packages
    echo    pip download torch torchaudio --index-url https://download.pytorch.org/whl/cpu -d pip_packages
    echo 2. Copy the 'pip_packages' folder here
    echo 3. Run this installer again
    echo.
    echo Attempting online installation...
    echo.

    echo Installing PyTorch (CPU version)...
    pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu

    echo.
    echo Installing NeMo and dependencies...
    pip install -r requirements.txt
)

if errorlevel 1 (
    echo.
    echo ERROR: Installation failed!
    echo.
    echo If you're on an offline machine, you need to create a package cache.
    echo See README_OFFLINE_SETUP.md for instructions.
    pause
    exit /b 1
)

echo.
echo Installing ffmpeg-python for audio format conversion...
pip install ffmpeg-python --no-index --find-links=pip_packages 2>nul
if errorlevel 1 (
    pip install ffmpeg-python
)

echo.
echo ============================================
echo Offline Installation Complete!
echo ============================================
echo.
echo Configuration:
echo   - Models: LOCAL (from 'models' folder)
echo   - Config: diar_infer_meeting_offline.yaml
echo   - Internet required: NO
echo.
echo IMPORTANT: For MP3/MP4/M4A support, you still need FFmpeg binaries:
echo   - Transfer ffmpeg.exe to this folder
echo   OR add FFmpeg to your system PATH
echo.
echo To run diarization:
echo   run_diarization.bat your_audio_file.wav
echo.
echo The system will automatically detect offline mode and use local models.
echo.
pause
