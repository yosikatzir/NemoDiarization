@echo off
REM NeMo Diarization Installation Script for Windows (CPU-only)
REM For corporate networks with trusted host requirements
REM Python 3.11.0+ required

echo ========================================
echo NeMo Diarization Setup for Windows
echo CPU-only version (Corporate Network)
echo ========================================
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
python -m pip install --upgrade pip --trusted-host pypi.org --trusted-host files.pythonhosted.org

echo.
echo Step 2: Installing PyTorch CPU version (Stage 1)...
echo This will download ~500MB of packages
echo CRITICAL: Installing PyTorch FIRST prevents 3GB of CUDA downloads!
pip install -r requirements_stage1_pytorch.txt --trusted-host nexuspro --trusted-host download.pytorch.org --trusted-host pypi.org --trusted-host files.pythonhosted.org

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PyTorch installation failed
    echo.
    echo Troubleshooting:
    echo 1. Check your internet connection
    echo 2. Verify proxy settings
    echo 3. Try manual installation:
    echo    pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu --trusted-host nexuspro --trusted-host download.pytorch.org
    pause
    exit /b 1
)

echo.
echo Step 3: Installing NeMo Toolkit and dependencies (Stage 2)...
echo This will download ~1.5GB of packages
pip install -r requirements_stage2_nemo.txt --trusted-host nexuspro --trusted-host pypi.org --trusted-host files.pythonhosted.org

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: NeMo installation failed
    pause
    exit /b 1
)

echo.
echo Step 4: Verifying installation...
python test_import.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo WARNING: Verification failed. Please check the error messages above.
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
echo - NeMo: 2.5.3
echo - NumPy: ^<2.0 (compatible with NeMo)
echo.
echo Next steps:
echo 1. Edit diarize.py and set AUDIO_FILE to your audio file path
echo 2. Run: python diarize.py
echo 3. Results will be in output/ directory
echo.
pause
