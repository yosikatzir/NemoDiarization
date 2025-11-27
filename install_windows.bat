@echo off
echo ============================================
echo NeMo Diarization - Windows 10 Setup
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python 3.8 or higher from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
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
python -m pip install --upgrade pip

echo.
echo Installing ffmpeg via pip (for audio format conversion)...
pip install ffmpeg-python

echo.
echo Installing PyTorch (CPU version for compatibility)...
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu

echo.
echo Installing NeMo and dependencies...
echo This may take several minutes...
pip install -r requirements.txt

echo.
echo ============================================
echo Installation complete!
echo ============================================
echo.
echo IMPORTANT: You also need FFmpeg binaries installed on your system
echo for audio format conversion (mp3, mp4, m4a support).
echo.
echo Download FFmpeg from: https://www.gyan.dev/ffmpeg/builds/
echo 1. Download "ffmpeg-release-essentials.zip"
echo 2. Extract the zip file
echo 3. Add the "bin" folder to your system PATH
echo    OR copy ffmpeg.exe to the same folder as this script
echo.
echo To test if FFmpeg is installed, open a new command prompt and type:
echo    ffmpeg -version
echo.
echo After FFmpeg is installed, you can run diarization with:
echo    run_diarization.bat your_audio_file.wav
echo.
pause
