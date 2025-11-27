import json
import os
from omegaconf import OmegaConf
from nemo.collections.asr.models.clustering_diarizer import ClusteringDiarizer

def create_manifest(audio_path, manifest_path):
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

if __name__ == "__main__":
    AUDIO_FILE = "audio2.wav"               # 👈 your input file
    MANIFEST_FILE = "input_manifest.json"   # auto-generated
    CONFIG_PATH = "diar_infer_meeting.yaml"

    # create manifest dynamically
    create_manifest(AUDIO_FILE, MANIFEST_FILE)

    # load config and patch only the manifest path (not other params)
    cfg = OmegaConf.load(CONFIG_PATH)
    cfg.diarizer.manifest_filepath = MANIFEST_FILE

    # run diarization
    model = ClusteringDiarizer(cfg=cfg)
    model.diarize()

    print("✅ Diarization complete.")
    print(f"Audio file: {AUDIO_FILE}")
    print(f"Manifest:  {MANIFEST_FILE}")
    print(f"Output dir: {cfg.diarizer.out_dir}")
