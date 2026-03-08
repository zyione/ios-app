#!/bin/bash
# Generate placeholder .caf sound files for the Interval Alarm app.
# Requires: sox (brew install sox) and afconvert (built-in on macOS).
# Usage: ./scripts/generate-sounds.sh

set -e

SOUNDS_DIR="IntervalAlarm/Resources/Sounds"

echo "Generating sound assets in $SOUNDS_DIR..."

# Generate .wav with sox, then convert to .caf with afconvert
generate() {
    local name="$1"
    shift
    echo "  $name.caf"
    sox "$@" "${SOUNDS_DIR}/${name}.wav"
    afconvert "${SOUNDS_DIR}/${name}.wav" "${SOUNDS_DIR}/${name}.caf" -d LEI16 -f caff
    rm "${SOUNDS_DIR}/${name}.wav"
}

generate "gentle_chime"   -n synth 2 sine 880 fade 0 2 1.5
generate "soft_bell"       -n synth 1.5 sine 1046.5 fade 0 1.5 1
generate "morning_tone"    -n synth 2 sine 659.25 fade 0 2 1.5
generate "digital_beep"    -n synth 0.5 square 1000 fade 0 0.5 0.3
generate "classic_alarm"   -n synth 3 sine 440:880 fade 0 3 0.5
generate "pulse"           -n synth 1 sine 523.25 sine 659.25 fade 0 1 0.5
generate "ripple"          -n synth 2.5 pluck 440 fade 0 2.5 2

echo "Done! Generated 7 sound files."
