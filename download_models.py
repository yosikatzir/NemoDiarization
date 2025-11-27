"""
Download NeMo pre-trained models for offline use.

Run this script on a machine with internet access to download all required models.
Then transfer the 'models' folder along with the rest of the package to the offline machine.
"""

import os
import sys
from pathlib import Path

def download_models():
    """Download all required NeMo models."""

    models_dir = Path("models")
    models_dir.mkdir(exist_ok=True)

    print("=" * 70)
    print("NeMo Model Downloader for Offline Installation")
    print("=" * 70)
    print()
    print("This script will download the following models:")
    print("  1. VAD Model: vad_multilingual_marblenet (~90 MB)")
    print("  2. Speaker Embedding: titanet_large (~100 MB)")
    print("  3. ASR Model: stt_en_conformer_ctc_large (~500 MB)")
    print()
    print(f"Models will be saved to: {models_dir.absolute()}")
    print()
    print("Total download size: ~690 MB")
    print("This may take 5-15 minutes depending on your internet speed...")
    print()

    try:
        from nemo.collections.asr.models import EncDecClassificationModel
        from nemo.collections.asr.models import EncDecSpeakerLabelModel
        from nemo.collections.asr.models import EncDecCTCModelBPE
    except ImportError:
        print("ERROR: NeMo toolkit is not installed!")
        print()
        print("Please install NeMo first:")
        print("  pip install nemo_toolkit[asr]")
        print()
        return False

    models_to_download = [
        {
            "name": "vad_multilingual_marblenet",
            "type": "VAD",
            "class": EncDecClassificationModel,
            "path": models_dir / "vad_multilingual_marblenet.nemo"
        },
        {
            "name": "titanet_large",
            "type": "Speaker Embedding",
            "class": EncDecSpeakerLabelModel,
            "path": models_dir / "titanet_large.nemo"
        },
        {
            "name": "stt_en_conformer_ctc_large",
            "type": "ASR",
            "class": EncDecCTCModelBPE,
            "path": models_dir / "stt_en_conformer_ctc_large.nemo"
        }
    ]

    print("Starting downloads...")
    print("-" * 70)

    for i, model_info in enumerate(models_to_download, 1):
        model_name = model_info["name"]
        model_type = model_info["type"]
        model_class = model_info["class"]
        save_path = model_info["path"]

        print(f"\n[{i}/3] Downloading {model_type}: {model_name}")

        if save_path.exists():
            print(f"  ✓ Already exists: {save_path.name}")
            continue

        try:
            print(f"  Downloading from NVIDIA NGC...")
            model = model_class.from_pretrained(model_name)
            model.save_to(str(save_path))

            # Verify file was created
            if save_path.exists():
                size_mb = save_path.stat().st_size / (1024 * 1024)
                print(f"  ✓ Downloaded successfully: {save_path.name} ({size_mb:.1f} MB)")
            else:
                print(f"  ✗ Failed to save model to {save_path}")
                return False

        except Exception as e:
            print(f"  ✗ Error downloading {model_name}: {e}")
            return False

    print()
    print("-" * 70)
    print("✓ All models downloaded successfully!")
    print("-" * 70)
    print()
    print("Downloaded models:")
    for model_info in models_to_download:
        path = model_info["path"]
        if path.exists():
            size_mb = path.stat().st_size / (1024 * 1024)
            print(f"  - {path.name} ({size_mb:.1f} MB)")

    print()
    print("Next steps:")
    print("  1. Copy the 'models' folder to your Windows package")
    print("  2. Transfer the complete package to your offline Windows machine")
    print("  3. The offline installation will automatically use these local models")
    print()

    return True

if __name__ == "__main__":
    print()
    success = download_models()

    if success:
        print("=" * 70)
        print("SUCCESS: Models ready for offline deployment")
        print("=" * 70)
        sys.exit(0)
    else:
        print()
        print("=" * 70)
        print("FAILED: Model download incomplete")
        print("=" * 70)
        print()
        print("Troubleshooting:")
        print("  - Check your internet connection")
        print("  - Ensure NeMo toolkit is installed: pip install nemo_toolkit[asr]")
        print("  - Try running the script again")
        sys.exit(1)
