#!/usr/bin/env python3
"""Test script to verify Linux Voice Control installation."""

import sys
import importlib.util

def test_import(module_name: str, package: str = None) -> bool:
    """Test if a module can be imported."""
    try:
        if package:
            module = importlib.import_module(f"{package}.{module_name}")
        else:
            module = importlib.import_module(module_name)
        print(f"✓ {module_name} imported successfully")
        return True
    except ImportError as e:
        print(f"✗ Failed to import {module_name}: {e}")
        return False

def main():
    """Run installation tests."""
    print("Linux Voice Control Installation Test")
    print("=" * 40)
    
    # Test core dependencies
    print("\nTesting core dependencies:")
    core_deps = [
        "click",
        "numpy",
        "termcolor",
        "tqdm",
        "pydub",
        "thefuzz",
        "gtts",
    ]
    
    core_success = all(test_import(dep) for dep in core_deps)
    
    # Test LVC modules
    print("\nTesting LVC modules:")
    lvc_modules = [
        "config_manager",
        "command_manager",
        "voice_feedback",
        "notifier",
        "utils",
        "basic_mode_manager",
        "chatgpt_port",
        "live_mode_manager",
        "master_mode_manager",
        "main",
    ]
    
    lvc_success = all(test_import(mod, "lvc") for mod in lvc_modules)
    
    # Test optional heavy dependencies
    print("\nTesting optional dependencies:")
    optional_deps = [
        ("pyaudio", "Audio input/output"),
        ("torch", "PyTorch for ML models"),
        ("transformers", "Hugging Face Transformers"),
        ("whisper", "OpenAI Whisper"),
        ("speechbrain", "SpeechBrain for voice matching"),
        ("librosa", "Audio processing"),
    ]
    
    for dep, desc in optional_deps:
        if test_import(dep):
            print(f"  └─ {desc}: Available")
        else:
            print(f"  └─ {desc}: Not installed (optional)")
    
    # Summary
    print("\n" + "=" * 40)
    if core_success and lvc_success:
        print("✓ Core installation successful!")
        print("\nYou can now run:")
        print("  uv run lvc")
        print("  uv run python -m lvc.main")
        return 0
    else:
        print("✗ Installation incomplete")
        print("\nPlease run:")
        print("  uv sync")
        return 1

if __name__ == "__main__":
    sys.exit(main())