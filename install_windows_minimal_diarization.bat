@echo off
REM NeMo Minimal Diarization Installation (NO ASR)
REM Perfect for Hebrew or any language - diarization only
REM NO C++ Build Tools required!
REM Python 3.11.0+ required

echo ========================================
echo NeMo Minimal Diarization Setup
echo Speaker Diarization ONLY - No ASR
echo ========================================
echo.
echo This installation:
echo  + Speaker diarization (who spoke when)
echo  + Multi-language support (Hebrew, English, etc.)
echo  + ~800MB installation size
echo  + NO C++ Build Tools required!
echo.
echo  - NO ASR/transcription
echo  - NO text output
echo  - Output: RTTM files with speaker timestamps only
echo.

REM Check Python version
python --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python not found. Please install Python 3.11.0+
    pause
    exit /b 1
)

echo.
echo Step 1: Upgrading pip...
python -m pip install --upgrade pip

echo.
echo Step 2: Installing PyTorch CPU version (Stage 1)...
echo This will download ~500MB
pip install -r requirements_stage1_pytorch.txt

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PyTorch installation failed
    pause
    exit /b 1
)

echo.
echo Step 3: Installing NeMo Minimal (Diarization Only)...
echo This will download ~800MB (vs ~2GB for full ASR)
echo NO C++ compilation required!
pip install -r requirements_minimal_diarization_only.txt

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: NeMo minimal installation failed
    pause
    exit /b 1
)

echo.
echo Step 4: Verifying installation...
python test_import.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo WARNING: Verification failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Installation Summary:
echo - PyTorch: 2.5.1 (CPU-only)
echo - NeMo: 2.5.3 (Diarization only)
echo - Total size: ~1.3GB (vs ~3GB with ASR)
echo - NO C++ Build Tools needed!
echo - Language: Hebrew, English, any language
echo.
echo Next steps:
echo 1. Edit diarize.py and set AUDIO_FILE to your Hebrew audio
echo 2. Run: python diarize.py
echo 3. Results: output/pred_rttms/*.rttm (speaker timestamps)
echo.
echo Output format: RTTM files showing:
echo - Who spoke (speaker_0, speaker_1, etc.)
echo - When they spoke (start time, duration)
echo - NO transcription (ASR disabled)
echo.
echo Note: First run will download models (~120MB)
echo.
pause
