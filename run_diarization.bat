@echo off
REM ============================================
REM Run NeMo Diarization on Windows
REM ============================================

if "%~1"=="" (
    echo Usage: run_diarization.bat ^<audio_file^>
    echo.
    echo Supported formats: wav, mp3, mp4, m4a
    echo.
    echo Example:
    echo   run_diarization.bat my_audio.wav
    echo   run_diarization.bat my_recording.mp3
    echo.
    pause
    exit /b 1
)

REM Check if file exists
if not exist "%~1" (
    echo ERROR: File not found: %~1
    echo.
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo.
    echo Please run install_windows.bat first to set up the environment.
    echo.
    pause
    exit /b 1
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo.
echo Running diarization on: %~1
echo.

python diarize_windows.py "%~1"

if errorlevel 1 (
    echo.
    echo Diarization failed. Please check the error message above.
    pause
    exit /b 1
)

echo.
echo ============================================
echo Press any key to exit...
pause >nul
