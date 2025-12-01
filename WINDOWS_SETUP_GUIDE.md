# NeMo Diarization Setup Guide for Windows (CPU-Only)

This guide will help you set up NeMo speaker diarization on a Windows machine without GPU, using Python 3.11.0.

## Prerequisites

- **Python 3.11.0** (or Python 3.11.x)
- **Windows 7, 8, 10, or 11** (64-bit)
- **No GPU required** (CPU-only setup)

## Important Notes

⚠️ **Performance Warning**: NeMo diarization on CPU is significantly slower than GPU inference (approximately 20x slower). For large audio files, expect longer processing times.

💡 **Tip**: The configuration file uses smaller models (e.g., `vad_multilingual_marblenet`) which are more suitable for CPU inference.

## Step-by-Step Installation

### 1. Create a Virtual Environment (Recommended)

```bash
python -m venv nemo_env
nemo_env\Scripts\activate
```

### 2. Upgrade pip

```bash
python -m pip install --upgrade pip
```

### 3. Install PyTorch CPU Version FIRST

**CRITICAL**: You must install PyTorch with the CPU index URL before installing other packages:

```bash
pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu
```

This command:
- Installs PyTorch 2.5.1 (CPU-only version, ~200MB instead of ~2GB)
- Avoids downloading unnecessary CUDA libraries
- Ensures compatibility with Windows CPU-only systems

### 4. Install NeMo Toolkit and Dependencies

After PyTorch is installed, install the remaining dependencies:

```bash
pip install -r requirements.txt --no-deps
pip install -r requirements.txt
```

Or install manually:

```bash
pip install nemo-toolkit[asr]==2.5.3
```

### 5. Verify Installation

Create a test script `test_import.py`:

```python
import torch
import nemo
from nemo.collections.asr.models.clustering_diarizer import ClusteringDiarizer

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"NeMo version: {nemo.__version__}")
print("✅ All imports successful!")
```

Run it:

```bash
python test_import.py
```

Expected output:
```
PyTorch version: 2.5.1+cpu
CUDA available: False
NeMo version: 2.5.3
✅ All imports successful!
```

## Running Diarization

### Basic Usage

1. Place your audio file (WAV format recommended) in the project directory
2. Update the `AUDIO_FILE` variable in `diarize.py` to point to your audio file
3. Run:

```bash
python diarize.py
```

### Expected Output

The script will:
- Create an `input_manifest.json` file
- Download required models on first run (VAD and speaker embedding models)
- Process the audio file
- Generate diarization results in the `output/` directory

Output files:
- `output/pred_rttms/*.rttm` - Diarization results in RTTM format
- Contains speaker segments with timestamps

### First Run Model Downloads

On the first run, NeMo will automatically download these models:
- **VAD Model**: `vad_multilingual_marblenet` (~20MB)
- **Speaker Embedding Model**: `titanet_large` (~100MB)

Models are cached in: `C:\Users\YourUsername\.cache\torch\NeMo\`

## Configuration Options

The `diar_infer_meeting.yaml` file controls diarization behavior:

### Key Settings for CPU Performance

```yaml
num_workers: 0          # Keep at 0 for CPU
batch_size: 32          # Reduce from 64 to 32 for CPU (lower memory usage)
device: "cpu"           # Force CPU usage
```

### Adjusting for Faster CPU Processing

Edit `diar_infer_meeting.yaml`:

```yaml
speaker_embeddings:
  model_path: titanet_small  # Use smaller model instead of titanet_large
  parameters:
    window_length_in_sec: [1.5]    # Single scale instead of [3.0,2.5,2.0]
    shift_length_in_sec: [0.75]    # Single scale instead of [1.5,1.25,1.0]
    multiscale_scales: [1]         # Single scale
    multiscale_weights: [1]        # Single scale
```

This will trade some accuracy for 2-3x faster processing on CPU.

## Troubleshooting

### Issue: "CUDA not available" warnings

This is normal for CPU-only setup. You can suppress these by setting the device explicitly:

In `diar_infer_meeting.yaml`:
```yaml
device: "cpu"
```

### Issue: Installation fails with "No matching distribution"

Make sure you're using 64-bit Python 3.11. Check with:
```bash
python --version
python -c "import struct; print(struct.calcsize('P') * 8, 'bit')"
```

### Issue: numpy compatibility error

NeMo 2.5.3 requires numpy<2.0. If you encounter errors, force install:
```bash
pip install "numpy>=1.24.0,<2.0.0"
```

### Issue: Slow performance

CPU inference is inherently slower. To improve:
1. Use shorter audio files (split long files into 5-10 minute segments)
2. Use smaller models (titanet_small instead of titanet_large)
3. Disable multiscale clustering (set to single scale)

### Issue: Out of memory

Reduce batch size in `diar_infer_meeting.yaml`:
```yaml
batch_size: 16  # or even 8 for very limited memory
```

## Performance Expectations

Typical processing times on modern CPU (Intel i7/i9 or AMD Ryzen 7):

| Audio Length | Processing Time (CPU) | Processing Time (GPU) |
|--------------|----------------------|-----------------------|
| 1 minute     | ~30-60 seconds       | ~2-3 seconds          |
| 5 minutes    | ~3-5 minutes         | ~10-15 seconds        |
| 30 minutes   | ~20-30 minutes       | ~1-2 minutes          |
| 1 hour       | ~40-60 minutes       | ~2-4 minutes          |

## Additional Resources

- [NeMo Toolkit Documentation](https://docs.nvidia.com/nemo-framework/user-guide/latest/)
- [NeMo GitHub Repository](https://github.com/NVIDIA-NeMo/NeMo)
- [PyTorch Documentation](https://pytorch.org/docs/)

## Support

For issues specific to:
- **NeMo functionality**: [NVIDIA NeMo GitHub Issues](https://github.com/NVIDIA-NeMo/NeMo/issues)
- **Windows installation**: Check Python and pip are 64-bit versions
- **Performance**: Consider using smaller models or cloud GPU instances for large-scale processing

## Version Information

- **NeMo Toolkit**: 2.5.3 (Latest as of December 2025)
- **PyTorch**: 2.5.1
- **Python**: 3.11.0+
- **Tested on**: Windows 10/11 (64-bit)
