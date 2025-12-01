# NeMo Speaker Diarization for Windows (CPU-Only)

This project provides a ready-to-use setup for speaker diarization using NVIDIA NeMo on Windows machines without GPU support.

## 📋 Overview

Speaker diarization is the process of partitioning an audio stream into homogeneous segments according to the speaker identity (answering "who spoke when?"). This implementation uses:

- **NeMo Toolkit 2.5.3** - NVIDIA's latest neural modules framework
- **PyTorch 2.5.1** - CPU-only version
- **Python 3.11** - Fully tested and compatible

## 🎯 Features

- ✅ No GPU required (CPU-only inference)
- ✅ Automatic VAD (Voice Activity Detection)
- ✅ Automatic speaker counting
- ✅ Multi-speaker support (up to 12 speakers)
- ✅ RTTM output format
- ✅ Pre-configured for meeting/conversation audio

## 📁 Project Structure

```
NemoDiarization/
├── diarize.py                  # Main diarization script
├── diar_infer_meeting.yaml     # Configuration file
├── requirements.txt            # Python dependencies
├── install_windows.bat         # Automated installation script
├── test_import.py              # Installation verification script
├── WINDOWS_SETUP_GUIDE.md      # Detailed setup instructions
└── README.md                   # This file
```

## 🚀 Quick Start (Windows)

### Option 1: Automated Installation (Recommended)

**For standard networks:**
```cmd
install_windows.bat
```

**For corporate networks (with proxy/trusted host):**
```cmd
install_windows_corporate.bat
```

The script will:
- Install PyTorch CPU version first (~500MB)
- Install NeMo and all dependencies (~1.5GB)
- Verify the installation automatically

### Option 2: Manual Installation (Two-Stage)

**⚠️ CRITICAL**: Installation order matters! PyTorch must be installed FIRST.

**Stage 1 - Install PyTorch CPU:**
```cmd
pip install -r requirements_stage1_pytorch.txt
```

*For corporate networks, add `--trusted-host nexuspro`:*
```cmd
pip install -r requirements_stage1_pytorch.txt --trusted-host nexuspro
```

**Stage 2 - Install NeMo:**
```cmd
pip install -r requirements_stage2_nemo.txt
```

*For corporate networks:*
```cmd
pip install -r requirements_stage2_nemo.txt --trusted-host nexuspro
```

**Verify:**
```cmd
python test_import.py
```

### Why Two-Stage Installation?

Installing PyTorch CPU **before** NeMo:
- ✅ Saves ~3GB (avoids downloading CUDA libraries)
- ✅ Ensures CPU-only operation
- ✅ Prevents version conflicts

Installing NeMo first:
- ❌ Downloads PyTorch with CUDA (~3GB wasted)
- ❌ May install incompatible numpy version
- ❌ Larger installation size

## 📊 System Requirements

| Requirement | Specification |
|------------|---------------|
| **OS** | Windows 7/8/10/11 (64-bit) |
| **Python** | 3.11.0 or higher |
| **RAM** | 8GB minimum, 16GB recommended |
| **Storage** | 2GB for dependencies + model cache |
| **GPU** | Not required (CPU-only) |
| **⚠️ C++ Build Tools** | **Required** - See installation notes below |

### ⚠️ Important: Windows Prerequisites

**NeMo requires Microsoft Visual C++ 14.0+ to compile some packages.**

**Quick Check:**
```cmd
where cl.exe
```

If not found, install Visual Studio Build Tools:
1. Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Install "Desktop development with C++"
3. Restart terminal

**Alternative solutions** (no compiler needed):
- Use pre-built wheels - See `WINDOWS_CPP_BUILD_TOOLS_FIX.md`
- Use Conda instead of pip - See `WINDOWS_CPP_BUILD_TOOLS_FIX.md`

## 🎵 Supported Audio Formats

- **WAV** (recommended) - 16kHz sample rate
- **MP3**, **FLAC**, **OGG** (auto-converted)
- Mono or stereo (will be converted to mono)

## 📈 Performance

CPU inference is slower than GPU but perfectly functional:

| Audio Length | Processing Time (Typical) |
|--------------|---------------------------|
| 1 minute     | ~30-60 seconds           |
| 5 minutes    | ~3-5 minutes             |
| 30 minutes   | ~20-30 minutes           |
| 1 hour       | ~40-60 minutes           |

*Times measured on Intel i7-9700K @ 3.6GHz. Your mileage may vary.*

## 🔧 Configuration

Edit `diar_infer_meeting.yaml` to customize:

### Basic Settings
```yaml
num_workers: 0        # Keep at 0 for CPU
batch_size: 32        # Reduce if out of memory
device: "cpu"         # Force CPU usage
```

### Model Selection
```yaml
vad:
  model_path: vad_multilingual_marblenet  # Voice activity detection

speaker_embeddings:
  model_path: titanet_large               # Speaker embedding model
  # Use titanet_small for faster CPU processing
```

### Speaker Count
```yaml
clustering:
  parameters:
    oracle_num_speakers: false      # Auto-detect speakers
    max_num_speakers: 12            # Maximum speakers to detect
```

## 📤 Output Format

Results are saved to `output/` directory:

- **RTTM files**: Standard diarization format
  ```
  SPEAKER audio2 1 0.50 2.30 <NA> <NA> speaker_0 <NA> <NA>
  SPEAKER audio2 1 3.10 1.80 <NA> <NA> speaker_1 <NA> <NA>
  ```

Format: `SPEAKER filename channel start_time duration <NA> <NA> speaker_label`

## 🐛 Troubleshooting

### "Microsoft Visual C++ 14.0 or greater is required" ⚠️ COMMON ON WINDOWS

**Error during installation:**
```
error: Microsoft Visual C++ 14.0 or greater is required.
```

**Solution:**
See detailed solutions in `WINDOWS_CPP_BUILD_TOOLS_FIX.md`

**Quick fix:**
1. Install Visual Studio Build Tools: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Select "Desktop development with C++"
3. Restart terminal and re-run installation

**Or use the Build Tools checker script:**
```cmd
install_windows_corporate_with_buildtools_check.bat
```

### "No matching distribution found for torch"

Make sure you're using the CPU index URL:
```cmd
pip install torch==2.5.1 --index-url https://download.pytorch.org/whl/cpu
```

### "numpy 2.x compatibility error"

NeMo requires numpy<2.0:
```cmd
pip install "numpy>=1.24.0,<2.0.0"
```

### Slow performance

- Use smaller models: Change `titanet_large` to `titanet_small` in config
- Reduce batch size: Set `batch_size: 16` in config
- Process shorter audio segments

### Out of memory

Reduce batch size in `diar_infer_meeting.yaml`:
```yaml
batch_size: 8  # or even smaller
```

## 📚 Additional Documentation

- **[WINDOWS_SETUP_GUIDE.md](WINDOWS_SETUP_GUIDE.md)** - Detailed setup instructions
- **[NeMo Documentation](https://docs.nvidia.com/nemo-framework/user-guide/latest/)** - Official NeMo docs
- **[NeMo GitHub](https://github.com/NVIDIA-NeMo/NeMo)** - Source code and examples

## 📋 Requirements File Details

The `requirements.txt` includes exact package versions tested on:
- **Date**: December 2025
- **Python**: 3.11.14
- **Platform**: Windows 10/11 64-bit
- **NeMo**: 2.5.3 (latest stable)

Key dependencies:
- `nemo-toolkit[asr]==2.5.3` - NeMo with ASR support
- `omegaconf==2.3.0` - Configuration management
- `soundfile==0.12.1` - Audio I/O
- `librosa==0.10.2.post1` - Audio processing
- `numpy>=1.24.0,<2.0.0` - NumPy (must be <2.0)
- `pytorch-lightning==2.4.0` - Training framework

## 🎓 Usage Example

```python
from omegaconf import OmegaConf
from nemo.collections.asr.models.clustering_diarizer import ClusteringDiarizer

# Load config
cfg = OmegaConf.load("diar_infer_meeting.yaml")
cfg.diarizer.manifest_filepath = "input_manifest.json"

# Run diarization
model = ClusteringDiarizer(cfg=cfg)
model.diarize()
```

## 🤝 Contributing

This is a pre-configured setup for Windows users. For NeMo development:
- Main repo: https://github.com/NVIDIA-NeMo/NeMo
- Issues: https://github.com/NVIDIA-NeMo/NeMo/issues

## 📄 License

This setup uses:
- **NeMo Toolkit**: Apache 2.0 License
- **PyTorch**: BSD-style License

See respective projects for full license terms.

## 🔗 References

- [NeMo Framework](https://www.nvidia.com/en-us/ai-data-science/products/nemo/)
- [Speaker Diarization Tutorial](https://github.com/NVIDIA-NeMo/NeMo/blob/main/tutorials/speaker_tasks/Speaker_Diarization_Inference.ipynb)
- [PyTorch](https://pytorch.org/)

## ⚡ Quick Reference

```bash
# Install
install_windows.bat

# Test
python test_import.py

# Run
python diarize.py

# Results
dir output\pred_rttms\*.rttm
```

---

**Version**: 1.0
**Last Updated**: December 2025
**Tested On**: Windows 10/11, Python 3.11, NeMo 2.5.3
