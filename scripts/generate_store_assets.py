"""Generate Play Store icon (512) and feature graphic (1024x500)."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "store-assets"
ICON_SRC = ROOT / "assets" / "images" / "icon.png"


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    icon = Image.open(ICON_SRC)
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(OUT / "play-store-icon-512.png")

    w, h = 1024, 500
    fg = Image.new("RGB", (w, h), "#1565C0")
    draw = ImageDraw.Draw(fg)
    for y in range(h):
        t = y / h
        r = int(21 + (33 - 21) * t)
        g = int(101 + (150 - 101) * t)
        b = int(192 + (243 - 192) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))

    logo = icon.resize((220, 220), Image.Resampling.LANCZOS)
    fg.paste(logo, (60, 140), logo if logo.mode == "RGBA" else None)

    try:
        font_big = ImageFont.truetype("arialbd.ttf", 72)
        font_sub = ImageFont.truetype("arial.ttf", 32)
    except OSError:
        font_big = ImageFont.load_default()
        font_sub = ImageFont.load_default()

    draw.text((320, 170), "VFD Hub", fill="white", font=font_big)
    draw.text((320, 270), "Configure drives. Tools for field engineers.", fill="#E3F2FD", font=font_sub)
    fg.save(OUT / "feature-graphic-1024x500.png")
    print(f"Wrote assets to {OUT}")


if __name__ == "__main__":
    main()
