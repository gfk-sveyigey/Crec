"""把 assetutil --info 的输出整理成可读清单。

用法：python3 tool/summarize_assets.py out/assets.json out/asset-names.txt

assetutil 输出的结构随 Xcode 版本略有差异，这里做兼容处理：
优先按 JSON 解析，失败则退化为正则抽取名字。
"""
import json
import re
import sys


def record_name(rec):
    for key in ("Name", "RenditionName", "name"):
        val = rec.get(key)
        if val:
            return str(val)
    return ""


def main():
    src, dst = sys.argv[1], sys.argv[2]
    raw = open(src, encoding="utf-8", errors="replace").read()

    try:
        data = json.loads(raw)
    except ValueError:
        data = None

    records = []
    if isinstance(data, list):
        records = [d for d in data if isinstance(d, dict)]
    elif isinstance(data, dict):
        for value in data.values():
            if isinstance(value, list):
                records = [d for d in value if isinstance(d, dict)]
                break

    out = []
    if records:
        out.append("renditions: %d" % len(records))

        colors = [
            r for r in records
            if str(r.get("AssetType", r.get("assetType", ""))).lower() == "color"
        ]
        out.append("")
        out.append("== named colors (%d) ==" % len(colors))
        for rec in colors:
            value = rec.get("Color components") or rec.get("Color") or rec.get("components")
            out.append("  %-44s %s" % (record_name(rec), value))

        names = sorted(set(n for n in (record_name(r) for r in records) if n))
        out.append("")
        out.append("== toolbar / tab icons ==")
        out.extend("  " + n for n in names if "toolbar" in n)
        out.append("")
        out.append("== all names (%d) ==" % len(names))
        out.extend(names)
    else:
        out.append("assets.json 不是 JSON，改用正则抽取名字")
        out.extend(sorted(set(re.findall(r'"([A-Za-z0-9_@.\-]{3,64})"', raw))))

    with open(dst, "w", encoding="utf-8") as fh:
        fh.write("\n".join(out) + "\n")

    print("\n".join(out[:150]))


if __name__ == "__main__":
    main()
