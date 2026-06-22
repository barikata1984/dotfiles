#!/usr/bin/env python3
"""Evdev hotkey daemon: voice input (F24) and BT profile toggle (F19)."""

import subprocess
import sys
import signal
import threading
import tempfile
from pathlib import Path
from selectors import DefaultSelector, EVENT_READ

import evdev
from evdev import ecodes

MODEL_ID = "deepdml/faster-whisper-large-v3-turbo-ct2"
WHISPER_SAMPLE_RATE = 16000
KEYBOARD_NAME = "Lily58 Keyboard"
IM_LANG_MAP = {"mozc": "ja", "keyboard-us": "en"}
BT_TOGGLE_SCRIPT = Path(__file__).resolve().parent.parent / "toggle-bt-profile.sh"

model = None
recording = False
rec_process = None
rec_tmpfile = None
_shutting_down = False


def find_keyboard():
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        if KEYBOARD_NAME in dev.name and ecodes.EV_KEY in dev.capabilities():
            return dev
    return None


def load_model():
    global model
    from faster_whisper import WhisperModel

    print("Loading model...")
    model = WhisperModel(MODEL_ID, device="cuda", compute_type="float16")
    print("Model loaded.")


def start_recording():
    global recording, rec_process, rec_tmpfile
    rec_tmpfile = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
    rec_process = subprocess.Popen(
        [
            "parecord",
            "--format=s16le",
            "--channels=1",
            f"--rate={WHISPER_SAMPLE_RATE}",
            "--file-format=wav",
            rec_tmpfile.name,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    recording = True
    print("Recording... (press F24 to stop)")


def stop_recording_and_transcribe():
    global recording, rec_process, rec_tmpfile
    if rec_process is not None:
        rec_process.send_signal(signal.SIGINT)
        rec_process.wait()
        rec_process = None
    recording = False

    tmp_path = rec_tmpfile.name
    rec_tmpfile.close()
    rec_tmpfile = None

    file_size = Path(tmp_path).stat().st_size
    if file_size < 1000:
        print("No audio captured.")
        Path(tmp_path).unlink(missing_ok=True)
        return

    lang = "ja"
    try:
        im = subprocess.run(
            ["fcitx5-remote", "-n"], capture_output=True, text=True
        ).stdout.strip()
        lang = IM_LANG_MAP.get(im, "ja")
    except FileNotFoundError:
        pass

    print(f"Transcribing (lang={lang}, im={im})...")
    segments, _ = model.transcribe(tmp_path, language=lang)
    text = " ".join(seg.text.strip() for seg in segments).strip()
    Path(tmp_path).unlink(missing_ok=True)

    if not text:
        print("No speech detected.")
        return

    print(f"Transcribed: {text}")
    subprocess.run(
        ["xdotool", "type", "--clearmodifiers", "--delay", "10", text],
        check=True,
    )


def toggle_bt_profile():
    print("Toggling BT profile...")
    subprocess.run(["bash", str(BT_TOGGLE_SCRIPT)])


def handle_key(code):
    global recording
    if code == ecodes.KEY_F24:
        if not recording:
            start_recording()
        else:
            threading.Thread(
                target=stop_recording_and_transcribe, daemon=True
            ).start()
    elif code == ecodes.KEY_F19:
        threading.Thread(target=toggle_bt_profile, daemon=True).start()


def cleanup_recording():
    global rec_process, rec_tmpfile, recording
    if rec_process is not None:
        rec_process.terminate()
        try:
            rec_process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            rec_process.kill()
            rec_process.wait()
        rec_process = None
    recording = False
    if rec_tmpfile is not None:
        Path(rec_tmpfile.name).unlink(missing_ok=True)
        rec_tmpfile.close()
        rec_tmpfile = None


def shutdown(signum, frame):
    global _shutting_down
    if _shutting_down:
        return
    _shutting_down = True
    cleanup_recording()
    sys.exit(0)


def main():
    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    kbd = find_keyboard()
    if kbd is None:
        print(f"Keyboard '{KEYBOARD_NAME}' not found. Available devices:")
        for path in evdev.list_devices():
            dev = evdev.InputDevice(path)
            print(f"  {dev.path}: {dev.name}")
        sys.exit(1)

    load_model()
    print(f"Listening on: {kbd.name} ({kbd.path})")
    print(f"  F19 → BT profile toggle ({BT_TOGGLE_SCRIPT})")
    print(f"  F24 → voice input toggle")

    selector = DefaultSelector()
    selector.register(kbd, EVENT_READ)

    try:
        while True:
            for key, mask in selector.select():
                device = key.fileobj
                for event in device.read():
                    if event.type == ecodes.EV_KEY and event.value == 1:
                        handle_key(event.code)
    finally:
        cleanup_recording()
        selector.close()


if __name__ == "__main__":
    main()
