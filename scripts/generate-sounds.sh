#!/bin/bash
# Generate 30-second looping .caf alarm sounds for RemindMeInX.
# Each sound plays a short pattern then repeats to fill 30 seconds.
# Requires: sox (brew install sox) and afconvert (built-in on macOS).
# Usage: ./scripts/generate-sounds.sh

set -e

SOUNDS_DIR="IntervalAlarm/Resources/Sounds"
DURATION=30  # iOS max notification sound length

echo "Generating ${DURATION}s sound assets in $SOUNDS_DIR..."

# Generate .wav with sox, then convert to .caf with afconvert
generate() {
    local name="$1"
    shift
    echo "  $name.caf (${DURATION}s)"
    sox -n "${SOUNDS_DIR}/${name}.wav" "$@"
    afconvert "${SOUNDS_DIR}/${name}.wav" "${SOUNDS_DIR}/${name}.caf" -d LEI16 -f caff
    rm "${SOUNDS_DIR}/${name}.wav"
}

# gentle_chime: 1s chime + 2s silence = 3s pattern, repeat 9x = 30s
generate "gentle_chime"   synth 1 sine 880 fade 0 1 0.8 pad 0 2 repeat 9

# soft_bell: 1s bell + 2s silence = 3s pattern, repeat 9x = 30s
generate "soft_bell"      synth 1 sine 1046.5 fade 0 1 0.7 pad 0 2 repeat 9

# morning_tone: 1.5s tone + 1.5s silence = 3s pattern, repeat 9x = 30s
generate "morning_tone"   synth 1.5 sine 659.25 fade 0 1.5 1 pad 0 1.5 repeat 9

# digital_beep: 0.3s beep + 2.7s silence = 3s pattern, repeat 9x = 30s
generate "digital_beep"   synth 0.3 square 1000 fade 0 0.3 0.1 pad 0 2.7 repeat 9

# classic_alarm: 2s rising siren + 1s silence = 3s pattern, repeat 9x = 30s
generate "classic_alarm"  synth 2 sine 440:880 fade 0 2 0.3 pad 0 1 repeat 9

# pulse: 0.5s dual-tone + 0.5s silence = 1s pattern, repeat 29x = 30s
generate "pulse"          synth 0.5 sine 523.25 sine 659.25 fade 0 0.5 0.3 pad 0 0.5 repeat 29

# ripple: 2s pluck + 1s silence = 3s pattern, repeat 9x = 30s
generate "ripple"         synth 2 pluck 440 fade 0 2 1.5 pad 0 1 repeat 9

# Convert any user-provided ringtone files (mp3/wav/m4a/m4r) to .caf
for ext in mp3 wav m4a m4r aac; do
    src="${SOUNDS_DIR}/ios_ringtone.${ext}"
    if [ -f "$src" ]; then
        echo "  Converting ios_ringtone.${ext} to .caf"
        afconvert "$src" "${SOUNDS_DIR}/ios_ringtone.caf" -d LEI16 -f caff
        rm "$src"
        break
    fi
done

echo "Done! Generated alarm sound files."
