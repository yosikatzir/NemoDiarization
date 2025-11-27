import json
import os
import sys
from pathlib import Path
from omegaconf import OmegaConf
from nemo.collections.asr.models.clustering_diarizer import ClusteringDiarizer

def create_manifest(audio_path, manifest_path):
    """Create a manifest file for the audio input."""
    data = {
        "audio_filepath": audio_path,
        "offset": 0,
        "duration": None,
        "label": "infer",
        "text": "-",
        "num_speakers": None
    }
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(data, f)
        f.write("\n")

def convert_audio_format(input_file, output_wav):
    """Convert audio file to WAV format if needed."""
    try:
        from pydub import AudioSegment

        input_ext = Path(input_file).suffix.lower()

        if input_ext == '.wav':
            return input_file

        print(f"Converting {input_ext} to WAV format...")

        if input_ext == '.mp3':
            audio = AudioSegment.from_mp3(input_file)
        elif input_ext == '.m4a':
            audio = AudioSegment.from_file(input_file, format='m4a')
        elif input_ext == '.mp4':
            audio = AudioSegment.from_file(input_file, format='mp4')
        else:
            print(f"Warning: Unsupported format {input_ext}, attempting generic conversion...")
            audio = AudioSegment.from_file(input_file)

        # Export as WAV with proper settings for NeMo
        audio = audio.set_channels(1)  # Mono
        audio = audio.set_frame_rate(16000)  # 16kHz sample rate
        audio.export(output_wav, format='wav')

        print(f"✓ Converted to: {output_wav}")
        return output_wav

    except ImportError:
        print("ERROR: pydub is not installed. Please run install_windows.bat")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Failed to convert audio file: {e}")
        print("\nMake sure FFmpeg is installed on your system.")
        print("Download from: https://www.gyan.dev/ffmpeg/builds/")
        sys.exit(1)

def check_offline_mode():
    """Check if we're running in offline mode with pre-downloaded models."""
    models_dir = Path("models")
    required_models = [
        "vad_multilingual_marblenet.nemo",
        "titanet_large.nemo"
    ]

    if not models_dir.exists():
        return False

    # Check if required models exist
    for model_file in required_models:
        if not (models_dir / model_file).exists():
            return False

    return True

def main(audio_file, config_path=None):
    """Main diarization function."""

    # Check if audio file exists
    if not os.path.exists(audio_file):
        print(f"ERROR: Audio file not found: {audio_file}")
        sys.exit(1)

    # Auto-detect offline mode and select appropriate config
    offline_mode = check_offline_mode()

    if config_path is None:
        if offline_mode:
            config_path = "diar_infer_meeting_offline.yaml"
            print("✓ Offline mode detected - using local models")
        else:
            config_path = "diar_infer_meeting.yaml"
            print("⚠ Online mode - models will be downloaded from internet")

    # Check if config file exists
    if not os.path.exists(config_path):
        print(f"ERROR: Config file not found: {config_path}")
        sys.exit(1)

    print("=" * 60)
    print("NeMo Speaker Diarization")
    print("=" * 60)
    print(f"Input audio: {audio_file}")
    print(f"Config file: {config_path}")

    # Convert to WAV if needed
    audio_path = Path(audio_file)
    if audio_path.suffix.lower() != '.wav':
        converted_wav = str(audio_path.with_suffix('.converted.wav'))
        audio_file = convert_audio_format(audio_file, converted_wav)
    else:
        audio_file = str(audio_path.resolve())

    # Create manifest
    manifest_file = "input_manifest.json"
    print(f"Creating manifest: {manifest_file}")
    create_manifest(audio_file, manifest_file)

    # Load config and update manifest path
    print(f"Loading config: {config_path}")
    cfg = OmegaConf.load(config_path)
    cfg.diarizer.manifest_filepath = manifest_file

    # Create output directory if it doesn't exist
    os.makedirs(cfg.diarizer.out_dir, exist_ok=True)

    print(f"Output directory: {cfg.diarizer.out_dir}")
    print("\nStarting diarization...")
    print("This may take several minutes depending on audio length...")
    print("-" * 60)

    try:
        # Run diarization
        model = ClusteringDiarizer(cfg=cfg)
        model.diarize()

        print("-" * 60)
        print("✓ Diarization complete!")
        print(f"\nResults saved to: {cfg.diarizer.out_dir}")
        print(f"  - RTTM file (speaker timestamps)")
        print(f"  - JSON file (detailed results)")

        # List output files
        output_dir = Path(cfg.diarizer.out_dir)
        if output_dir.exists():
            output_files = list(output_dir.glob('*'))
            if output_files:
                print("\nOutput files:")
                for f in output_files:
                    print(f"  - {f.name}")

    except Exception as e:
        print(f"\nERROR during diarization: {e}")
        print("\nTroubleshooting:")

        if offline_mode:
            print("1. Verify all model files exist in the 'models' folder")
            print("2. Check that your audio file is valid")
            print("3. Ensure you have enough disk space")
        else:
            print("1. Make sure you have internet connection (models need to be downloaded)")
            print("2. If offline, download models using download_models.py on an internet-connected machine")
            print("3. Check that your audio file is valid")
            print("4. Ensure you have enough disk space")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python diarize_windows.py <audio_file> [config_file]")
        print("\nSupported formats: wav, mp3, mp4, m4a")
        print("\nExample:")
        print("  python diarize_windows.py my_audio.wav")
        print("  python diarize_windows.py my_audio.mp3 diar_infer_meeting_offline.yaml")
        print("\nNote: Config file is auto-detected based on presence of 'models' folder")
        print("      - With models folder: uses diar_infer_meeting_offline.yaml")
        print("      - Without models folder: uses diar_infer_meeting.yaml (requires internet)")
        sys.exit(1)

    audio_file = sys.argv[1]
    config_file = sys.argv[2] if len(sys.argv) > 2 else None

    main(audio_file, config_file)
