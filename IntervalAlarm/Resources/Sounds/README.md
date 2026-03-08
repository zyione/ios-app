# Sound Assets

These .caf files must be created on macOS before building the app.

## Required files

- gentle_chime.caf
- soft_bell.caf
- morning_tone.caf
- digital_beep.caf
- classic_alarm.caf
- pulse.caf
- ripple.caf

## How to create placeholder sounds on Mac

Use `afconvert` to convert any .wav or .mp3 to .caf:

    afconvert input.wav output.caf -d LEI16 -f caff

Or generate simple tones with `sox` (install via `brew install sox`):

    sox -n gentle_chime.caf synth 2 sine 880 fade 0 2 1.5
    sox -n soft_bell.caf synth 1.5 sine 1046.5 fade 0 1.5 1
    sox -n morning_tone.caf synth 2 sine 659.25 fade 0 2 1.5
    sox -n digital_beep.caf synth 0.5 square 1000 fade 0 0.5 0.3
    sox -n classic_alarm.caf synth 3 sine 440:880 fade 0 3 0.5
    sox -n pulse.caf synth 1 sine 523.25 sine 659.25 fade 0 1 0.5
    sox -n ripple.caf synth 2.5 pluck 440 fade 0 2.5 2

## Notification sound constraints

- Maximum 30 seconds
- Supported formats: .caf, .wav, .aiff
- Must be in app bundle (not on-demand resources)
