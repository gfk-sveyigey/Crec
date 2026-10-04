from PIL import Image
import os, json, sys

ROOT = r"G:/Github/Crec"
src = Image.open(os.path.join(ROOT, "icon.png")).convert("RGBA")
print("source size:", src.size)

def square(img, size):
    side = min(img.size)
    left = (img.size[0] - side) // 2
    top = (img.size[1] - side) // 2
    cropped = img.crop((left, top, left + side, top + side))
    return cropped.resize((size, size), Image.LANCZOS)

# ---- Android launcher icons
android = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, size in android.items():
    out_dir = os.path.join(ROOT, "android", "app", "src", "main", "res", folder)
    os.makedirs(out_dir, exist_ok=True)
    square(src, size).save(os.path.join(out_dir, "ic_launcher.png"), "PNG")
print("android icons done")

# ---- iOS AppIcon set
ios_dir = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
os.makedirs(ios_dir, exist_ok=True)
specs = [
    ("Icon-App-20x20@1x.png", 20, "iphone", "1x"),
    ("Icon-App-20x20@2x.png", 40, "iphone", "2x"),
    ("Icon-App-20x20@3x.png", 60, "iphone", "3x"),
    ("Icon-App-29x29@1x.png", 29, "iphone", "1x"),
    ("Icon-App-29x29@2x.png", 58, "iphone", "2x"),
    ("Icon-App-29x29@3x.png", 87, "iphone", "3x"),
    ("Icon-App-40x40@1x.png", 40, "iphone", "1x"),
    ("Icon-App-40x40@2x.png", 80, "iphone", "2x"),
    ("Icon-App-40x40@3x.png", 120, "iphone", "3x"),
    ("Icon-App-60x60@2x.png", 120, "iphone", "2x"),
    ("Icon-App-60x60@3x.png", 180, "iphone", "3x"),
    ("Icon-App-76x76@1x.png", 76, "ipad", "1x"),
    ("Icon-App-76x76@2x.png", 152, "ipad", "2x"),
    ("Icon-App-83.5x83.5@2x.png", 167, "ipad", "2x"),
    ("Icon-App-1024x1024@1x.png", 1024, "ios-marketing", "1x"),
]
images = []
for name, size, idiom, scale in specs:
    square(src, size).save(os.path.join(ios_dir, name), "PNG")
    images.append({"size": (str(size) + "x" + str(size)), "idiom": idiom, "filename": name, "scale": scale})
with open(os.path.join(ios_dir, "Contents.json"), "w", encoding="utf-8") as fh:
    json.dump({"images": images, "info": {"version": 1, "author": "xcode"}}, fh, indent=2)
print("ios icons done:", len(specs))

# ---- shared asset used inside the app
os.makedirs(os.path.join(ROOT, "assets", "images"), exist_ok=True)
square(src, 512).save(os.path.join(ROOT, "assets", "images", "logo.png"), "PNG")
print("app logo done")
