# uses speechbrain to analyze master voice
# author: @omegaui
# github: https://github.com/omegaui/linux-voice-control
# license: GNU GPL v3

import os.path

try:
    from speechbrain.pretrained import SpeakerRecognition
    SPEECHBRAIN_AVAILABLE = True
except ImportError:
    SPEECHBRAIN_AVAILABLE = False
    print("Warning: speechbrain not installed. Master mode voice verification will be disabled.")


# @return True if master-mode configuration is ready
def canEnableMasterMode():
    return os.path.exists('training-data/master-mode')


# uses speechbrain to check if the current mic fetched audio is same as the master mode sample audio
def isMasterSpeaking():
    if not SPEECHBRAIN_AVAILABLE:
        print("Warning: Master mode voice verification is disabled (speechbrain not installed)")
        return True  # Allow all voices when speechbrain is not available
    
    verification = SpeakerRecognition.from_hparams(source="speechbrain/spkrec-ecapa-voxceleb",
                                                   savedir="pretrained_models/spkrec-ecapa-voxceleb")
    for i in range(1, 4):
        score, prediction = verification.verify_files(f"training-data/master_mode_audio_sample{i}.wav",
                                                      "misc/last-mic-fetch.wav")
        if not not prediction[0]:
            return True
    return False
