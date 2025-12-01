@echo off
REM NeMo Diarization Installation Script for Windows (CPU-only)
REM Python 3.11.0 required

echo ========================================
echo NeMo Diarization Setup for Windows
echo CPU-only version (no GPU required)
echo ========================================
echo.

REM Check Python version
python --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python not found. Please install Python 3.11.0
    pause
    exit /b 1
)

echo.
echo Step 1: Upgrading pip...
python -m pip install --upgrade pip

echo.
echo Step 2: Installing PyTorch CPU version...
echo This will download ~200MB of packages
pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PyTorch installation failed
    pause
    exit /b 1
)

echo.
echo Step 3: Installing NeMo Toolkit and dependencies...
echo This will download ~500MB of packages
pip install nemo-toolkit[asr]==2.5.3

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: NeMo installation failed
    pause
    exit /b 1
)

echo.
echo Step 4: Installing additional dependencies from requirements.txt...
pip install -r requirements.txt

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo To verify the installation, run:
echo   python test_import.py
echo.
echo To run diarization on an audio file:
echo   1. Edit diarize.py and set AUDIO_FILE to your audio file path
echo   2. Run: python diarize.py
echo.
pause
