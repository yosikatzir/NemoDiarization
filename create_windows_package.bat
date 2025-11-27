@echo off
REM Script to create Windows deployment package (can run on Windows)

set PACKAGE_NAME=NemoDiarization_Windows10
set OUTPUT_ZIP=%PACKAGE_NAME%.zip

echo ================================================
echo Creating Windows 10 Deployment Package
echo ================================================
echo.

REM Check if 7-Zip or PowerShell is available
where powershell >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell not found
    echo This script requires PowerShell to create zip files
    pause
    exit /b 1
)

REM Files to include
set FILES=diarize_windows.py diar_infer_meeting.yaml requirements.txt install_windows.bat run_diarization.bat README_WINDOWS.md QUICKSTART.txt

echo Checking files...
set missing=0
for %%f in (%FILES%) do (
    if exist "%%f" (
        echo   [OK] Found: %%f
    ) else (
        echo   [X] Missing: %%f
        set /a missing+=1
    )
)

if %missing% gtr 0 (
    echo.
    echo Error: %missing% file(s) missing. Cannot create package.
    pause
    exit /b 1
)

echo.
echo Creating zip package using PowerShell...

REM Remove old package if exists
if exist "%OUTPUT_ZIP%" (
    del "%OUTPUT_ZIP%"
    echo   Removed old package
)

REM Create zip using PowerShell
powershell -Command "Compress-Archive -Path %FILES% -DestinationPath '%OUTPUT_ZIP%' -Force"

if exist "%OUTPUT_ZIP%" (
    echo.
    echo ================================================
    echo Package created successfully!
    echo ================================================
    echo   File: %OUTPUT_ZIP%
    echo.
    echo This package contains:
    for %%f in (%FILES%) do echo   - %%f
    echo.
    echo Next steps:
    echo 1. Transfer %OUTPUT_ZIP% to your Windows 10 machine
    echo 2. Extract the ZIP file
    echo 3. Follow instructions in QUICKSTART.txt
    echo.
) else (
    echo.
    echo Error: Failed to create package
    pause
    exit /b 1
)

pause
