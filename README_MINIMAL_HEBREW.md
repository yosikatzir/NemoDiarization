# NeMo Speaker Diarization - Minimal Installation (Perfect for Hebrew!)

## Quick Start for Hebrew Audio Diarization

This minimal installation is perfect for:
- ✅ Hebrew audio files
- ✅ Any language (language-independent)
- ✅ Speaker diarization only (who spoke when)
- ✅ No ASR/transcription needed
- ✅ NO C++ Build Tools required!
- ✅ Smaller installation (~1.3GB vs ~3GB)
- ✅ Faster installation
- ✅ Corporate networks friendly

## What You Get

**Output: RTTM files** showing:
- Speaker labels (speaker_0, speaker_1, speaker_2, etc.)
- Timestamps (when each speaker spoke)
- Duration of each speech segment

**Example RTTM output:**
```
SPEAKER audio_hebrew 1 0.50 2.30 <NA> <NA> speaker_0 <NA> <NA>
SPEAKER audio_hebrew 1 3.10 1.80 <NA> <NA> speaker_1 <NA> <NA>
SPEAKER audio_hebrew 1 5.20 3.45 <NA> <NA> speaker_0 <NA> <NA>
```

**What you DON'T get:**
- ❌ No transcription/text
- ❌ No speech-to-text
- ❌ No word-level timestamps

(For Hebrew transcription, use external tools like Whisper after diarization)

## Installation (2 Steps)

### Option 1: Standard Network

```cmd
install_windows_minimal_diarization.bat
```

### Option 2: Corporate Network (with proxy/trusted host)

```cmd
install_windows_minimal_corporate.bat
```

### Manual Installation

```cmd
# Step 1: PyTorch CPU
pip install -r requirements_stage1_pytorch.txt

# Step 2: NeMo Minimal
pip install -r requirements_minimal_diarization_only.txt

# Verify
python test_import.py
```

## Usage

1. **Place your Hebrew audio file** in the project directory
   ```
   my_hebrew_meeting.wav
   ```

2. **Edit diarize.py:**
   ```python
   AUDIO_FILE = "my_hebrew_meeting.wav"
   CONFIG_PATH = "diar_infer_meeting_no_asr.yaml"  # ASR disabled
   ```

3. **Run diarization:**
   ```cmd
   python diarize.py
   ```

4. **Check results:**
   ```
   output/pred_rttms/my_hebrew_meeting.rttm
   ```

## Why This Works for Hebrew

Speaker diarization is **language-independent** because it uses:

1. **Acoustic features** - Voice characteristics (pitch, timbre, rhythm)
2. **Speaker embeddings** - Neural "voice fingerprints"
3. **Clustering** - Grouping similar voices

These work the same for:
- Hebrew (עברית)
- English
- Arabic (العربية)
- Russian (Русский)
- Any language!

## Configuration File

Use `diar_infer_meeting_no_asr.yaml` (provided):
- ASR disabled (model_path: null)
- Multilingual VAD model
- Language-independent speaker embeddings
- Optimized for meetings (3-12 speakers)

## Installation Size Comparison

| Installation Type | Size | C++ Build Tools? | ASR? |
|-------------------|------|------------------|------|
| **Minimal** (this) | ~1.3GB | ❌ No | ❌ No |
| Full ASR | ~3GB | ✅ Yes | ✅ Yes |
| With CUDA (wrong!) | ~6GB | ✅ Yes | ✅ Yes |

## Benefits of Minimal Installation

1. **No Compilation Errors**
   - No ctc_segmentation (requires MSVC)
   - No texterrors (requires MSVC)
   - No kaldi-python-io
   - Works on any Windows PC!

2. **Faster Installation**
   - Fewer packages to download
   - No compilation step
   - ~15 minutes vs ~45 minutes

3. **Smaller Disk Usage**
   - ~1.3GB total vs ~3GB
   - Good for limited storage

4. **Perfect for Hebrew**
   - No English ASR model (unused)
   - Just speaker timestamps
   - Combine with external Hebrew ASR if needed

## Adding Hebrew Transcription (Optional)

After diarization, you can add Hebrew transcription:

### Option 1: Whisper (OpenAI)

```python
import whisper

# Load Hebrew Whisper model
model = whisper.load_model("medium")

# Transcribe with Hebrew
result = model.transcribe("audio.wav", language="he")
print(result["text"])
```

### Option 2: wav2vec2-hebrew

From Hugging Face:
```python
from transformers import pipeline

asr = pipeline("automatic-speech-recognition",
               model="imvladikon/wav2vec2-xls-r-300m-hebrew")
result = asr("audio.wav")
```

### Option 3: Google Cloud Speech-to-Text

Supports Hebrew natively via API.

## Combining Diarization + Hebrew ASR

```python
# 1. Run NeMo diarization (get speaker timestamps)
# Output: speaker_0 spoke 0.5-2.8s, speaker_1 spoke 3.1-4.9s

# 2. Run Hebrew ASR (get text)
# Output: "שלום, מה שלומך?"

# 3. Combine:
# speaker_0 (0.5-2.8s): "שלום"
# speaker_1 (3.1-4.9s): "מה שלומך?"
```

## System Requirements

| Requirement | Specification |
|------------|---------------|
| **OS** | Windows 7/8/10/11 (64-bit) |
| **Python** | 3.11.0 or higher |
| **RAM** | 8GB minimum, 16GB recommended |
| **Storage** | 2GB free space |
| **GPU** | Not required (CPU-only) |
| **C++ Build Tools** | ❌ **NOT required** (minimal install) |

## Troubleshooting

### "ModuleNotFoundError: No module named 'transformers'"

This is expected! Minimal installation doesn't include ASR.
- Make sure you're using `diar_infer_meeting_no_asr.yaml`
- Or set `asr.model_path: null` in your config

### Slow performance

CPU inference is slower than GPU:
- 1 min audio → ~30-60 sec processing
- 10 min audio → ~5-10 min processing
- Use smaller models (titanet_small) for faster processing

### Out of memory

Reduce batch size in config:
```yaml
batch_size: 32  # or even 16
```

## Files Included

```
NemoDiarization/
├── requirements_stage1_pytorch.txt           # PyTorch CPU
├── requirements_minimal_diarization_only.txt # Minimal NeMo
├── install_windows_minimal_diarization.bat   # Standard install
├── install_windows_minimal_corporate.bat     # Corporate install
├── diar_infer_meeting_no_asr.yaml           # Config (ASR disabled)
├── diarize.py                                # Main script
└── README_MINIMAL_HEBREW.md                  # This file
```

## Support

- **Hebrew audio**: Fully supported ✅
- **Multi-speaker**: Up to 12 speakers ✅
- **Overlap detection**: Supported ✅
- **Transcription**: Use external Hebrew ASR tools

## Quick Reference

```bash
# Install
install_windows_minimal_corporate.bat

# Run
python diarize.py

# Results
dir output\pred_rttms\*.rttm
```

---

**Perfect for Hebrew meetings, podcasts, interviews, and any multi-speaker Hebrew audio!**

עובד מצוין עם אודיו בעברית! 🎉
