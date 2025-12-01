@echo off
REM NeMo Diarization Installation Script for Windows (CPU-only)
REM With Visual C++ Build Tools check
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
echo ========================================
echo Checking for Microsoft Visual C++ Build Tools...
echo ========================================
echo.

REM Check for cl.exe (Visual C++ compiler)
where cl.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo *** WARNING: Microsoft Visual C++ Build Tools NOT FOUND ***
    echo.
    echo NeMo requires C++ Build Tools to compile some packages:
    echo - ctc_segmentation
    echo - texterrors
    echo.
    echo You have 3 options:
    echo.
    echo Option 1: Install Visual C++ Build Tools [RECOMMENDED]
    echo    1. Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo    2. Run installer and select "Desktop development with C++"
    echo    3. Restart this script after installation
    echo.
    echo Option 2: Try installation anyway [MAY FAIL]
    echo    - Installation may fail when building C extensions
    echo    - Some NeMo features may not work
    echo.
    echo Option 3: See WINDOWS_CPP_BUILD_TOOLS_FIX.md for alternatives
    echo    - Pre-built wheels
    echo    - Conda installation
    echo.
    set /p choice="Continue anyway? (y/n): "
    if /i not "%choice%"=="y" (
        echo.
        echo Installation cancelled. Please install Visual C++ Build Tools and try again.
        echo See WINDOWS_CPP_BUILD_TOOLS_FIX.md for detailed instructions.
        pause
        exit /b 1
    )
    echo.
    echo Continuing installation without Build Tools...
    echo Note: Installation may fail when compiling C extensions.
    echo.
) else (
    echo Visual C++ Build Tools found!
    cl.exe 2>&1 | findstr /C:"Microsoft"
    echo.
)

echo.
echo Step 1: Upgrading pip...
python -m pip install --upgrade pip --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host nexuspro

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
    echo    pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu --trusted-host nexuspro
    pause
    exit /b 1
)

echo.
echo Step 3: Installing NeMo Toolkit and dependencies (Stage 2)...
echo This will download ~1.5GB of packages
echo.
echo NOTE: This step may fail if Visual C++ Build Tools are not installed.
echo If you see compilation errors, see WINDOWS_CPP_BUILD_TOOLS_FIX.md
echo.
pip install -r requirements_stage2_nemo.txt --trusted-host nexuspro --trusted-host pypi.org --trusted-host files.pythonhosted.org

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo ERROR: NeMo installation failed
    echo ========================================
    echo.
    echo This is likely due to missing Visual C++ Build Tools.
    echo.
    echo Two packages require compilation:
    echo - ctc_segmentation
    echo - texterrors
    echo.
    echo SOLUTIONS:
    echo.
    echo 1. Install Visual C++ Build Tools [RECOMMENDED]:
    echo    - Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo    - Install "Desktop development with C++"
    echo    - Restart this script
    echo.
    echo 2. Use pre-built wheels [FASTER]:
    echo    - See WINDOWS_CPP_BUILD_TOOLS_FIX.md for instructions
    echo    - Download wheels from unofficial repository
    echo.
    echo 3. Use Conda instead of pip:
    echo    - See WINDOWS_CPP_BUILD_TOOLS_FIX.md for Conda instructions
    echo.
    echo For detailed instructions, read:
    echo    WINDOWS_CPP_BUILD_TOOLS_FIX.md
    echo.
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
echo - Visual C++ Build Tools: Detected and used
echo.
echo Next steps:
echo 1. Edit diarize.py and set AUDIO_FILE to your audio file path
echo 2. Run: python diarize.py
echo 3. Results will be in output/ directory
echo.
echo Note: First run will download models (~120MB)
echo.
pause
