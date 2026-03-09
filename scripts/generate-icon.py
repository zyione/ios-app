#!/usr/bin/env python3
"""Generate the RemindMeInX app icon (1024x1024 PNG).

Requires: pip3 install Pillow
"""
import os
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
AMBER = (255, 171, 64)
DARK = (28, 28, 30)
CARD = (44, 44, 46)

img = Image.new("RGB", (SIZE, SIZE), DARK)
draw = ImageDraw.Draw(img)

# Rounded rectangle background
draw.rounded_rectangle(
    [60, 60, SIZE - 60, SIZE - 60],
    radius=200,
    fill=CARD,
)

# Large amber "R" in the center
font = None
font_paths = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]
for path in font_paths:
    try:
        font = ImageFont.truetype(path, 520)
        break
    except (OSError, IOError):
        continue

if font is None:
    # Fallback: use default font scaled up
    font = ImageFont.load_default()

# Draw the letter
bbox = draw.textbbox((0, 0), "R", font=font)
text_w = bbox[2] - bbox[0]
text_h = bbox[3] - bbox[1]
x = (SIZE - text_w) // 2 - bbox[0]
y = (SIZE - text_h) // 2 - bbox[1]
draw.text((x, y), "R", fill=AMBER, font=font)

# Small bell icon below the R (simple circle + triangle)
bell_cx = SIZE // 2
bell_cy = y + text_h + 60
bell_r = 28
# Bell dome
draw.ellipse(
    [bell_cx - bell_r, bell_cy - bell_r, bell_cx + bell_r, bell_cy + bell_r],
    fill=AMBER,
)
# Bell body
draw.polygon(
    [
        (bell_cx - bell_r - 10, bell_cy + bell_r - 5),
        (bell_cx + bell_r + 10, bell_cy + bell_r - 5),
        (bell_cx + bell_r + 20, bell_cy + bell_r + 25),
        (bell_cx - bell_r - 20, bell_cy + bell_r + 25),
    ],
    fill=AMBER,
)
# Bell clapper
draw.ellipse(
    [bell_cx - 8, bell_cy + bell_r + 25, bell_cx + 8, bell_cy + bell_r + 41],
    fill=AMBER,
)

# Save
output_dir = "IntervalAlarm/Resources/Assets.xcassets/AppIcon.appiconset"
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "app-icon-1024.png")
img.save(output_path)
print(f"Generated app icon: {output_path}")
