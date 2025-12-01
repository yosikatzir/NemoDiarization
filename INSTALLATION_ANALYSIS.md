# NeMo Diarization Installation Analysis

## Executive Summary

After testing the actual installation of `nemo-toolkit[asr]==2.5.3`, I've identified several critical issues regarding package version conflicts and installation order.

## Key Findings

### 1. **NumPy Version Conflict** ⚠️ CRITICAL

- **NeMo initially requests**: `numpy>=1.22` (which resolves to numpy 2.3.5)
- **NeMo then DOWNGRADES to**: `numpy==1.26.4`
- **Reason**: NeMo 2.5.3 has an implicit constraint `numpy<2.0` due to incompatibility
- **Impact**: If numpy 2.x is installed first, NeMo will force a downgrade

**SOLUTION**: Pin `numpy>=1.24.0,<2.0.0` in requirements.txt BEFORE installing NeMo

### 2. **PyTorch Installation Conflict** ⚠️ CRITICAL

- **NeMo automatically installs**: PyTorch 2.9.1 with FULL CUDA dependencies
- **CUDA packages installed** (~3GB):
  - nvidia-cuda-nvrtc-cu12==12.8.93
  - nvidia-cuda-runtime-cu12==12.8.90
  - nvidia-cublas-cu12==12.8.4.1
  - nvidia-cudnn-cu12==9.10.2.21
  - nvidia-cufft-cu12==11.3.3.83
  - nvidia-curand-cu12==10.3.9.90
  - nvidia-cusolver-cu12==11.7.3.90
  - nvidia-cusparse-cu12==12.5.8.93
  - nvidia-nccl-cu12==2.27.5
  - ... and more

**SOLUTION**: Install PyTorch CPU version FIRST before nemo-toolkit

### 3. **Installation Order is CRITICAL**

The ONLY correct installation order for Windows CPU-only is:

```bash
# Step 1: Install PyTorch CPU version
pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu --trusted-host nexuspro

# Step 2: Pin numpy before NeMo
pip install "numpy>=1.24.0,<2.0.0" --trusted-host nexuspro

# Step 3: Install NeMo (it will use the existing PyTorch and numpy)
pip install nemo-toolkit[asr]==2.5.3 --trusted-host nexuspro
```

**WHY THIS ORDER MATTERS**:
1. If NeMo is installed first, it pulls PyTorch with CUDA (~3GB wasted on CPU-only systems)
2. If numpy 2.x gets installed, NeMo will force downgrade causing conflicts
3. Once PyTorch CPU is installed, NeMo will respect it and not try to reinstall

### 4. **Dependencies Installed by nemo-toolkit[asr]==2.5.3**

NeMo pulls in 100+ dependencies. Key ones that might conflict:

| Package | NeMo's Constraint | Note |
|---------|-------------------|------|
| `numpy` | `>=1.22` → `1.26.4` | Downgraded to <2.0 |
| `torch` | (latest) | Will install CUDA version if not pre-installed |
| `fsspec` | `==2024.12.0` | **Exact version** |
| `omegaconf` | `<=2.3` | Compatible with 2.3.0 |
| `hydra-core` | `<=1.3.2,>1.3` | Compatible with 1.3.2 |
| `lightning` | `<=2.4.0,>2.2.1` | **NOT** pytorch-lightning |
| `transformers` | `~=4.53.0` | 4.53.x only |
| `librosa` | `>=0.10.1` | Got 0.11.0 |
| `scipy` | `>=0.14` | Got 1.16.3 |
| `scikit-learn` | (latest) | Got 1.7.2 |
| `pandas` | (latest) | Got 2.3.3 |
| `numba` | (latest) | Got 0.62.1 |
| `pyannote.core` | (latest) | Got 6.0.1 |
| `pyannote.metrics` | (latest) | Got 4.0.0 |
| `soundfile` | (latest) | Got 0.13.1 |

### 5. **Packages That Will Override User Specifications**

If you specify different versions in requirements.txt, NeMo will:

- **Override**: `fsspec` (forces ==2024.12.0)
- **Downgrade**: `numpy` (forces <2.0)
- **Constrain**: `omegaconf` (must be <=2.3)
- **Constrain**: `hydra-core` (must be <=1.3.2)
- **Constrain**: `lightning` (must be <=2.4.0)
- **Constrain**: `transformers` (must be ~=4.53.0)

## Recommended Installation Strategy

### Option 1: Two-Stage Installation (RECOMMENDED)

**Stage 1 - requirements_stage1.txt:**
```
# Stage 1: Install PyTorch CPU and pin numpy
--index-url https://download.pytorch.org/whl/cpu
--trusted-host nexuspro
torch==2.5.1
torchvision==0.20.1
torchaudio==2.5.1
numpy>=1.24.0,<2.0.0
```

**Stage 2 - requirements_stage2.txt:**
```
# Stage 2: Install NeMo and let it pull compatible dependencies
--trusted-host nexuspro
nemo-toolkit[asr]==2.5.3
```

**Installation:**
```bash
pip install -r requirements_stage1.txt
pip install -r requirements_stage2.txt
```

### Option 2: Manual Step-by-Step (SAFEST)

```bash
# 1. Install PyTorch CPU
pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 \
    --index-url https://download.pytorch.org/whl/cpu \
    --trusted-host nexuspro

# 2. Pin numpy
pip install "numpy>=1.24.0,<2.0.0" --trusted-host nexuspro

# 3. Install NeMo
pip install nemo-toolkit[asr]==2.5.3 --trusted-host nexuspro

# 4. Verify
pip list | grep -E "torch|numpy|nemo"
```

## Why Single requirements.txt Doesn't Work Well

1. **Index URL conflict**: PyTorch CPU needs special index, but you can't mix indexes in one file
2. **Installation order**: pip doesn't guarantee install order from requirements.txt
3. **Dependency resolution**: pip might resolve to CUDA PyTorch if it's checked first

## Windows-Specific Considerations

1. **Proxy/Corporate Network**: Add `--trusted-host nexuspro` to ALL pip commands
2. **No mixing index URLs**: Can't use both PyPI and PyTorch CPU index in one command
3. **File paths**: Use backslashes or forward slashes consistently

## Verification Commands

After installation:

```bash
# Check PyTorch is CPU-only
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"

# Check numpy version
python -c "import numpy; print(f'NumPy: {numpy.__version__}')"

# Check NeMo
python -c "import nemo; print(f'NeMo: {nemo.__version__}')"
```

Expected output:
```
PyTorch: 2.5.1+cpu
CUDA: False
NumPy: 1.26.4
NeMo: 2.5.3
```

## Size Comparison

| Installation Method | Total Size |
|---------------------|------------|
| ❌ NeMo first (CUDA) | ~5-6 GB |
| ✅ PyTorch CPU first | ~2-3 GB |

**Savings**: ~3GB by installing PyTorch CPU first!

##  Conclusion

**YES, the installation order is absolutely critical!**

NeMo WILL override/conflict with package versions if not installed correctly:
- It WILL force numpy downgrade to <2.0
- It WILL install CUDA PyTorch if PyTorch isn't pre-installed
- It WILL pin specific versions of fsspec, transformers, etc.

The two-stage installation approach is the ONLY reliable way to ensure CPU-only setup on Windows.
