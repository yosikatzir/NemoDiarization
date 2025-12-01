# NeMo Speaker Diarization - Minimal Setup (Hebrew/Multi-Language)

**Perfect for Hebrew audio or any language - Speaker diarization without ASR transcription**

This is a streamlined, minimal installation of NVIDIA NeMo for speaker diarization ONLY. Perfect for Hebrew (עברית), Arabic (العربية), Russian (Русский), or any language.

## 🎯 What You Get

**Output: Speaker timestamps in RTTM format**
- Who spoke (speaker_0, speaker_1, etc.)
- When they spoke (start time + duration)
- Works with any language (language-independent)

**Example output:**
```
SPEAKER my_audio 1 0.50 2.30 <NA> <NA> speaker_0 <NA> <NA>
SPEAKER my_audio 1 3.10 1.80 <NA> <NA> speaker_1 <NA> <NA>
```

## ✅ Benefits

- ✅ **NO C++ Build Tools required** (no Visual Studio needed!)
- ✅ **Smaller installation** (~1.3GB vs ~3GB)
- ✅ **Faster installation** (~15 min vs ~45 min)
- ✅ **Multi-language** (Hebrew, English, any language)
- ✅ **Corporate network friendly** (--trusted-host support)
- ✅ **No compilation errors** on Windows

## 📊 System Requirements

| Requirement | Specification |
|------------|---------------|
| **OS** | Windows 7/8/10/11 (64-bit) |
| **Python** | 3.11.0 or higher |
| **RAM** | 8GB minimum, 16GB recommended |
| **Storage** | 2GB free space |
| **GPU** | Not required (CPU-only) |
| **C++ Build Tools** | ❌ **NOT required!** |

## 🚀 Quick Start

### Step 1: Install

**For standard networks:**
```cmd
install_windows_minimal_diarization.bat
```

**For corporate networks (with proxy/trusted-host):**
```cmd
install_windows_minimal_corporate.bat
```

**Manual installation:**
```cmd
# Install PyTorch CPU
pip install -r requirements_stage1_pytorch.txt

# Install NeMo minimal
pip install -r requirements_minimal_diarization_only.txt

# Verify
python test_import.py
```

### Step 2: Prepare Your Audio

Place your audio file in the project directory:
```
my_hebrew_audio.wav
```

### Step 3: Edit diarize.py

```python
AUDIO_FILE = "my_hebrew_audio.wav"  # Your audio file
```

### Step 4: Run Diarization

```cmd
python diarize.py
```

### Step 5: Get Results

Results in `output/pred_rttms/`:
```cmd
dir output\pred_rttms\*.rttm
```

## 📁 Project Structure

```
NemoDiarization/
├── diarize.py                                  # Main script
├── diar_infer_meeting_no_asr.yaml             # Config (ASR disabled)
├── requirements_stage1_pytorch.txt             # PyTorch CPU
├── requirements_minimal_diarization_only.txt   # NeMo minimal
├── install_windows_minimal_diarization.bat     # Standard installer
├── install_windows_minimal_corporate.bat       # Corporate installer
├── test_import.py                              # Verification script
├── .gitignore                                  # Git ignore rules
└── README.md                                   # This file
```

## 🎵 Supported Audio Formats

- **WAV** (recommended) - 16kHz sample rate
- **MP3**, **FLAC**, **OGG** (auto-converted)
- Mono or stereo (will be converted to mono)

## ⚙️ Configuration

Edit `diar_infer_meeting_no_asr.yaml` to customize:

```yaml
# Number of speakers
clustering:
  parameters:
    max_num_speakers: 12  # Adjust based on your audio

# Performance tuning
batch_size: 32  # Reduce if out of memory (16 or 8)

# Speaker embedding model
speaker_embeddings:
  model_path: titanet_large  # or titanet_small for faster processing
```

## 📈 Performance Expectations (CPU)

| Audio Length | Processing Time |
|--------------|----------------|
| 1 minute     | ~30-60 seconds |
| 5 minutes    | ~3-5 minutes   |
| 30 minutes   | ~20-30 minutes |
| 1 hour       | ~40-60 minutes |

*Times on Intel i7/i9 or AMD Ryzen 7*

## 🌍 Language Support

**Speaker diarization is language-independent!**

Works perfectly with:
- ✅ Hebrew (עברית)
- ✅ Arabic (العربية)
- ✅ English
- ✅ Russian (Русский)
- ✅ Chinese (中文)
- ✅ Spanish (Español)
- ✅ French (Français)
- ✅ German (Deutsch)
- ✅ **Any language!**

Why? Diarization uses acoustic features (voice characteristics), not language understanding.

## 💬 Adding Hebrew Transcription (Optional)

Want text output? Use external Hebrew ASR after diarization:

### Option 1: Whisper (OpenAI)

```python
import whisper
model = whisper.load_model("medium")
result = model.transcribe("audio.wav", language="he")
print(result["text"])
```

### Option 2: wav2vec2-hebrew (Hugging Face)

```python
from transformers import pipeline
asr = pipeline("automatic-speech-recognition",
               model="imvladikon/wav2vec2-xls-r-300m-hebrew")
result = asr("audio.wav")
```

### Option 3: Google Cloud Speech-to-Text

Use Google's API with Hebrew language support.

## 🐛 Troubleshooting

### Slow performance

- Use smaller model: `speaker_embeddings.model_path: titanet_small`
- Reduce batch size: `batch_size: 16`
- Process shorter audio segments

### Out of memory

```yaml
batch_size: 8  # or even smaller
```

### First run downloads models

Normal! First run downloads:
- VAD model (~20MB)
- Speaker embedding model (~100MB)

Models cached in: `C:\Users\YourUsername\.cache\torch\NeMo\`

### "ModuleNotFoundError"

Run verification:
```cmd
python test_import.py
```

If fails, reinstall:
```cmd
install_windows_minimal_corporate.bat
```

## 📦 Installation Size

| Component | Size |
|-----------|------|
| PyTorch CPU | ~500MB |
| NeMo Core | ~300MB |
| Dependencies | ~500MB |
| **Total** | **~1.3GB** |

Compare to full ASR: ~3GB ✨ Save 1.7GB!

## 🔧 Corporate Network Setup

All scripts support `--trusted-host nexuspro`:

```cmd
# Install PyTorch
pip install -r requirements_stage1_pytorch.txt --trusted-host nexuspro

# Install NeMo
pip install -r requirements_minimal_diarization_only.txt --trusted-host nexuspro
```

Or use the corporate installer:
```cmd
install_windows_minimal_corporate.bat
```

## 📚 What's NOT Included

This minimal installation does NOT include:
- ❌ ASR/transcription
- ❌ Language models
- ❌ Text processing
- ❌ ctc_segmentation (no C++ compilation!)
- ❌ texterrors (no C++ compilation!)
- ❌ Training capabilities
- ❌ Transformers library

For diarization only, you don't need these! 🎉

## 🎓 Example Use Case

```python
# 1. Run diarization
python diarize.py

# 2. Read RTTM output
# output/pred_rttms/my_audio.rttm:
# speaker_0: 0.0-5.2s
# speaker_1: 5.5-8.3s
# speaker_0: 8.5-12.1s

# 3. (Optional) Add Hebrew transcription with external tool
# Combine speaker labels + Hebrew text
```

## 🆘 Support

**For questions:**
- Check `test_import.py` output
- Review `output/` folder for results
- See RTTM format documentation

**Common issues:**
- Ensure Python 3.11+ (64-bit)
- Check audio file format (WAV recommended)
- Verify sufficient disk space (2GB+)

## 📄 License

This setup uses:
- **NeMo Toolkit**: Apache 2.0 License
- **PyTorch**: BSD-style License

## ⭐ Quick Reference

```bash
# Install
install_windows_minimal_corporate.bat

# Run
python diarize.py

# Results
dir output\pred_rttms\*.rttm

# Verify
python test_import.py
```

---

**עובד מצוין עם אודיו בעברית! Works great with Hebrew audio! 🇮🇱**

**يعمل بشكل ممتاز مع الصوت العربي! Works great with Arabic audio! 🇸🇦**

**Отлично работает с русским аудио! Works great with Russian audio! 🇷🇺**

---

**Version**: 1.0 (Minimal - No ASR)
**Last Updated**: December 2025
**Python**: 3.11.0+
**NeMo**: 2.5.3
**Platform**: Windows 10/11 (64-bit)
