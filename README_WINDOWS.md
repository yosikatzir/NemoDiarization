# NeMo Diarization for Windows 10

This package contains everything you need to perform speaker diarization on Windows 10 using NVIDIA NeMo toolkit.

## What is Speaker Diarization?

Speaker diarization answers the question "who spoke when?" in an audio file. It identifies different speakers and generates timestamps showing when each speaker was talking.

## Supported Audio Formats

- **WAV** (.wav) - Recommended, native format
- **MP3** (.mp3) - Automatically converted
- **MP4** (.mp4) - Audio extracted and converted
- **M4A** (.m4a) - Automatically converted

## Prerequisites

### 1. Python Installation

- **Python 3.8 or higher** is required
- Download from: https://www.python.org/downloads/
- **IMPORTANT**: During installation, check the box "Add Python to PATH"

### 2. FFmpeg Installation (Required for MP3/MP4/M4A support)

FFmpeg is needed to convert audio formats:

1. Download FFmpeg from: https://www.gyan.dev/ffmpeg/builds/
2. Download the **"ffmpeg-release-essentials.zip"** file
3. Extract the zip file to a folder (e.g., `C:\ffmpeg`)
4. Add FFmpeg to your system PATH:
   - Right-click "This PC" → Properties → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find and select "Path"
   - Click "Edit" → "New"
   - Add the path to FFmpeg's `bin` folder (e.g., `C:\ffmpeg\bin`)
   - Click OK on all windows

**Alternative**: Copy `ffmpeg.exe` from the `bin` folder directly into this NemoDiarization folder.

To verify FFmpeg is installed, open Command Prompt and type:
```
ffmpeg -version
```

## Installation Steps

1. **Extract this package** to a folder on your Windows 10 machine (e.g., `C:\NemoDiarization`)

2. **Open Command Prompt** in the package folder:
   - Navigate to the folder in File Explorer
   - Type `cmd` in the address bar and press Enter

3. **Run the installation script**:
   ```
   install_windows.bat
   ```

   This will:
   - Create a Python virtual environment
   - Install PyTorch (CPU version for compatibility)
   - Install NeMo toolkit and all dependencies
   - This may take 10-20 minutes depending on your internet speed

4. **Wait for installation to complete**
   - The script will download several gigabytes of dependencies
   - You'll see "Installation complete!" when done

## How to Use

### Basic Usage

1. **Place your audio file** in the NemoDiarization folder (or note its full path)

2. **Run diarization**:
   ```
   run_diarization.bat your_audio_file.wav
   ```

   Or for other formats:
   ```
   run_diarization.bat my_recording.mp3
   run_diarization.bat interview.m4a
   run_diarization.bat video.mp4
   ```

3. **Wait for processing**
   - First run will download pre-trained models (this happens only once)
   - Processing time depends on audio length (roughly 1x to 2x real-time)

4. **Check results**
   - Results are saved in the `output` folder
   - Look for `.rttm` files (speaker timestamp format)
   - JSON files contain detailed speaker information

### Understanding the Output

The output folder contains:

- **`.rttm` file**: Speaker timeline in RTTM format
  - Format: `SPEAKER filename 1 start_time duration <NA> <NA> speaker_id <NA> <NA>`
  - Example: `SPEAKER audio2 1 0.50 2.35 <NA> <NA> speaker_0 <NA> <NA>`
    - Speaker 0 spoke from 0.50s for 2.35 seconds

- **`.json` file**: Detailed diarization results in JSON format

## Configuration

The `diar_infer_meeting.yaml` file contains all diarization parameters. You can modify:

- **Number of speakers**: Set `oracle_num_speakers: True` and specify `num_speakers` in manifest if you know the exact count
- **VAD sensitivity**: Adjust `onset` and `offset` values (lines 32-33)
- **Output directory**: Change `out_dir` value (default is "output")

## Troubleshooting

### "Python is not installed or not in PATH"
- Install Python from https://www.python.org/downloads/
- Make sure to check "Add Python to PATH" during installation
- Restart Command Prompt after installation

### "ERROR: Failed to convert audio file"
- Install FFmpeg (see prerequisites above)
- Make sure FFmpeg is in your system PATH or in the same folder
- Test with: `ffmpeg -version`

### "Model download failed" or network errors
- Ensure you have a stable internet connection
- Models are downloaded from NVIDIA NGC on first run
- Total download size: ~500MB-1GB for all models

### "Out of memory" errors
- The configuration uses CPU by default for compatibility
- For large audio files (>1 hour), consider processing in smaller chunks
- Close other applications to free up RAM

### Diarization results are poor
- Try adjusting the YAML configuration parameters
- Ensure audio quality is good (clear speech, minimal background noise)
- The default config works best for meetings with 3-5 speakers
- For different scenarios, you may need to tune VAD and clustering parameters

## Advanced Usage

### Using a Different Configuration File

```
python diarize_windows.py my_audio.wav custom_config.yaml
```

### Running from Python Directly

Activate the virtual environment first:
```
venv\Scripts\activate
python diarize_windows.py your_audio.wav
```

### Processing Multiple Files

Create a batch script to process multiple files:
```batch
@echo off
for %%f in (*.wav) do (
    echo Processing %%f
    run_diarization.bat "%%f"
)
```

## System Requirements

- **OS**: Windows 10 (64-bit)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 10GB free space (for dependencies and models)
- **Internet**: Required for initial model download

## What's Included

- `diarize_windows.py` - Main diarization script (supports multiple formats)
- `diar_infer_meeting.yaml` - Configuration file (optimized for meetings)
- `requirements.txt` - Python dependencies
- `install_windows.bat` - Installation script
- `run_diarization.bat` - Easy-to-use runner script
- `README_WINDOWS.md` - This documentation file

## Models Used

The system automatically downloads these pre-trained models on first run:

1. **VAD Model**: `vad_multilingual_marblenet` - Detects speech activity
2. **Speaker Embedding**: `titanet_large` - Extracts speaker characteristics
3. **ASR Model** (optional): `stt_en_conformer_ctc_large` - For transcript generation

All models are downloaded from NVIDIA NGC and cached locally.

## Support and Resources

- **NeMo Documentation**: https://docs.nvidia.com/deeplearning/nemo/user-guide/docs/
- **NeMo GitHub**: https://github.com/NVIDIA/NeMo
- **Speaker Diarization Tutorial**: https://docs.nvidia.com/deeplearning/nemo/user-guide/docs/en/main/asr/speaker_diarization/intro.html

## License

This package uses NVIDIA NeMo toolkit, which is licensed under Apache License 2.0.

## Notes

- First run will be slower due to model downloads
- Models are cached and reused for subsequent runs
- CPU version is used by default for maximum compatibility
- For GPU acceleration, you'll need CUDA-compatible GPU and drivers (advanced setup)
