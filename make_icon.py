"""
Generate ikon aplikasi Tokoku.

Desain: latar hijau gelap dengan gradient halus, tas belanja krem,
handle emas, dan huruf T hijau. Menghasilkan:
  - ikon legacy Android (mipmap-*/ic_launcher.png)
  - ikon bulat Android (mipmap-*/ic_launcher_round.png)
  - adaptive icon Android 8+ (foreground + background + XML)
  - master PNG 1024px untuk preview / Play Store

Jalankan: python make_icon.py
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# ── Palet ────────────────────────────────────────────────────────────────
GREEN_DARK  = (0x14, 0x3D, 0x2E)
GREEN_MID   = (0x2A, 0x6B, 0x50)
GREEN_TEXT  = (0x1B, 0x4A, 0x38)
CREAM       = (0xF9, 0xF5, 0xEA)
CREAM_DARK  = (0xEC, 0xE1, 0xC6)
GOLD        = (0xE4, 0xB9, 0x5B)

# ── Font ─────────────────────────────────────────────────────────────────
FONT_PATH = None
for _p in [
    "C:/Windows/Fonts/segoeuib.ttf",
    "C:/Windows/Fonts/arialbd.ttf",
    "C:/Windows/Fonts/arial.ttf",
]:
    if os.path.exists(_p):
        FONT_PATH = _p
        break

MASTER = 1024
ROOT = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
ASSETS = os.path.join(ROOT, "assets", "icon")


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(size, c1, c2):
    """Gradient diagonal, dibuat kecil lalu diperbesar agar halus."""
    small = Image.new("RGB", (128, 128))
    px = small.load()
    for y in range(128):
        for x in range(128):
            px[x, y] = lerp(c1, c2, (x + y) / 254)
    return small.resize((size, size), Image.LANCZOS)


def rounded_mask(size, radius_ratio=0.22, circle=False):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    if circle:
        d.ellipse([0, 0, size - 1, size - 1], fill=255)
    else:
        d.rounded_rectangle([0, 0, size - 1, size - 1],
                            radius=int(size * radius_ratio), fill=255)
    return mask


def background(size, circle=False):
    """Latar hijau bergradient + glow + border tipis."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mask = rounded_mask(size, 0.22, circle)
    img.paste(gradient(size, GREEN_DARK, GREEN_MID), (0, 0), mask)

    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [-size * 0.35, -size * 0.45, size * 0.75, size * 0.65],
        fill=(255, 255, 255, 24),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.12))
    img = Image.alpha_composite(
        img,
        Image.composite(glow, Image.new("RGBA", (size, size), (0, 0, 0, 0)), mask),
    )

    d = ImageDraw.Draw(img)
    d.rounded_rectangle(
        [size * 0.012, size * 0.012, size * 0.988, size * 0.988],
        radius=int(size * 0.21),
        outline=(255, 255, 255, 20),
        width=max(2, int(size * 0.004)),
    )
    return img


def composition(size):
    """Tas + handle + huruf T di kanvas transparan."""
    s = size
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))

    # bayangan tas
    sh = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [s * 0.20, s * 0.44, s * 0.80, s * 0.865],
        radius=s * 0.11, fill=(0, 0, 0, 80),
    )
    sh = sh.filter(ImageFilter.GaussianBlur(s * 0.035))
    img = Image.alpha_composite(img, sh)

    d = ImageDraw.Draw(img)

    # handle emas: setengah lingkaran, ujung masuk ke balik badan tas
    hw = int(s * 0.056)
    d.arc([s * 0.305, s * 0.195, s * 0.695, s * 0.685],
          start=180, end=360, fill=GOLD, width=hw)

    # badan tas dengan gradient vertikal
    left, right = s * 0.20, s * 0.80
    top, bottom = s * 0.41, s * 0.85
    body = Image.new("RGB", (s, s))
    px = body.load()
    for y in range(int(top), int(bottom) + 1):
        t = (y - top) / (bottom - top)
        col = lerp(CREAM, CREAM_DARK, t * t)
        for x in range(int(left), int(right) + 1):
            px[x, y] = col
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [left, top, right, bottom], radius=s * 0.105, fill=255
    )
    img.paste(body, (0, 0), mask)

    # huruf T
    font = ImageFont.truetype(FONT_PATH, int(s * 0.31))
    d = ImageDraw.Draw(img)
    d.text((s * 0.5, s * 0.645), "T", font=font, fill=GREEN_TEXT, anchor="mm")
    return img


def legacy_icon(size, circle=False):
    img = background(size, circle)
    comp = composition(size)
    img = Image.alpha_composite(img, comp)
    if circle:
        mask = rounded_mask(size, circle=True)
        out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        out.paste(img, (0, 0), mask)
        img = out
    return img


def adaptive_foreground(size):
    """Komposisi tas diperkecil agar aman di dalam safe zone adaptive icon.

    Seluruh kanvas komposisi diperkecil 0.82x, jadi lebar tas ±53dp dari
    108dp — masuk ke safe zone lingkaran 66dp tanpa terpotong masker.
    """
    comp = composition(MASTER)
    scaled_size = max(1, int(size * 0.82))
    comp = comp.resize((scaled_size, scaled_size), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset = (size - scaled_size) // 2
    canvas.paste(comp, (offset, offset), comp)
    return canvas


def adaptive_background(size):
    """Latar penuh tanpa sudut membulat; masker dilakukan launcher."""
    return gradient(size, GREEN_DARK, GREEN_MID).convert("RGBA")


def full_icon(size):
    """Ikon persegi penuh (tanpa sudut transparan) untuk iOS/web/favicon."""
    img = gradient(size, GREEN_DARK, GREEN_MID).convert("RGBA")
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [-size * 0.35, -size * 0.45, size * 0.75, size * 0.65],
        fill=(255, 255, 255, 24),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.12))
    img = Image.alpha_composite(img, glow)
    return Image.alpha_composite(img, composition(size))


LEGACY_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

ADAPTIVE_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"  {path}")


def main():
    print("Membuat ikon legacy + bulat...")
    for folder, px in LEGACY_SIZES.items():
        save(legacy_icon(px), os.path.join(RES, folder, "ic_launcher.png"))
        save(legacy_icon(px, circle=True), os.path.join(RES, folder, "ic_launcher_round.png"))

    print("Membuat layer adaptive icon...")
    for folder, px in ADAPTIVE_SIZES.items():
        save(adaptive_background(px), os.path.join(RES, folder, "ic_launcher_background.png"))
        save(adaptive_foreground(px), os.path.join(RES, folder, "ic_launcher_foreground.png"))

    # XML adaptive icon (Android 8+)
    anydpi = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(anydpi, name), "w", encoding="utf-8", newline="\n") as f:
            f.write(xml)
        print(f"  {os.path.join(anydpi, name)}")

    print("Membuat ikon iOS...")
    ios_dir = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    ios_icons = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for name, px in ios_icons.items():
        path = os.path.join(ios_dir, name)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        full_icon(px).convert("RGB").save(path, "PNG", optimize=True)
        print(f"  {path}")

    print("Membuat ikon macOS...")
    macos_dir = os.path.join(ROOT, "macos", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for px in (16, 32, 64, 128, 256, 512, 1024):
        save(legacy_icon(px), os.path.join(macos_dir, f"app_icon_{px}.png"))

    print("Membuat ikon web...")
    web_dir = os.path.join(ROOT, "web", "icons")
    for name, px, masked in (
        ("Icon-192.png", 192, False),
        ("Icon-512.png", 512, False),
        ("Icon-maskable-192.png", 192, True),
        ("Icon-maskable-512.png", 512, True),
    ):
        icon = full_icon(px) if masked else legacy_icon(px)
        save(icon, os.path.join(web_dir, name))
    save(full_icon(32), os.path.join(ROOT, "web", "favicon.png"))

    print("Membuat ikon Windows...")
    ico_path = os.path.join(ROOT, "windows", "runner", "resources", "app_icon.ico")
    legacy_icon(256).save(
        ico_path, format="ICO",
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )
    print(f"  {ico_path}")

    # Master & preview
    save(legacy_icon(MASTER), os.path.join(ASSETS, "tokoku_icon_1024.png"))
    save(legacy_icon(512), os.path.join(ASSETS, "tokoku_icon_512.png"))

    print("Selesai.")


if __name__ == "__main__":
    main()
