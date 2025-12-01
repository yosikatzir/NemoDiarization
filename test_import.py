"""
Test script to verify NeMo diarization installation on Windows CPU
"""
import sys

def test_imports():
    """Test all required imports for NeMo diarization"""
    print("=" * 60)
    print("Testing NeMo Diarization Installation")
    print("=" * 60)
    print()

    # Test Python version
    print(f"✓ Python version: {sys.version}")
    python_version = sys.version_info
    if python_version.major != 3 or python_version.minor < 10:
        print("  ⚠ WARNING: Python 3.10+ recommended, you have:",
              f"{python_version.major}.{python_version.minor}")
    print()

    # Test PyTorch
    try:
        import torch
        print(f"✓ PyTorch version: {torch.__version__}")
        print(f"  - CUDA available: {torch.cuda.is_available()}")
        if torch.cuda.is_available():
            print(f"  - CUDA version: {torch.version.cuda}")
        else:
            print("  - Running on CPU (expected for CPU-only setup)")
        print()
    except ImportError as e:
        print(f"✗ PyTorch import failed: {e}")
        return False

    # Test NeMo
    try:
        import nemo
        print(f"✓ NeMo version: {nemo.__version__}")
        print()
    except ImportError as e:
        print(f"✗ NeMo import failed: {e}")
        return False

    # Test OmegaConf
    try:
        from omegaconf import OmegaConf
        print(f"✓ OmegaConf imported successfully")
    except ImportError as e:
        print(f"✗ OmegaConf import failed: {e}")
        return False

    # Test NeMo ASR components
    try:
        from nemo.collections.asr.models.clustering_diarizer import ClusteringDiarizer
        print(f"✓ NeMo ClusteringDiarizer imported successfully")
    except ImportError as e:
        print(f"✗ NeMo ClusteringDiarizer import failed: {e}")
        return False

    # Test audio libraries
    try:
        import soundfile
        print(f"✓ soundfile version: {soundfile.__version__}")
    except ImportError as e:
        print(f"✗ soundfile import failed: {e}")
        return False

    try:
        import librosa
        print(f"✓ librosa version: {librosa.__version__}")
    except ImportError as e:
        print(f"✗ librosa import failed: {e}")
        return False

    # Test numpy version (must be <2.0)
    try:
        import numpy as np
        print(f"✓ numpy version: {np.__version__}")
        if int(np.__version__.split('.')[0]) >= 2:
            print("  ⚠ WARNING: numpy 2.x detected, NeMo requires numpy <2.0")
            print("  Run: pip install 'numpy<2.0'")
            return False
    except ImportError as e:
        print(f"✗ numpy import failed: {e}")
        return False

    print()
    print("=" * 60)
    print("✓ All imports successful!")
    print("=" * 60)
    print()
    print("You can now run diarization with: python diarize.py")
    print()

    return True

if __name__ == "__main__":
    success = test_imports()
    sys.exit(0 if success else 1)
