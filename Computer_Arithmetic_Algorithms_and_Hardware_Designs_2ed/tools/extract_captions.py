# -*- coding: utf-8 -*-
"""从原书 PDF 提取全部图题的英文原文，生成图注清单 JSON。

与 extract_figures.py 配套：为每张已剪裁的 PNG 找回它在原书中的图题文字，
供撰写中文图注时参考。

用法：
    python extract_captions.py <pdf_path> <images_dir> <out_json>
"""
import json
import re
import sys
from pathlib import Path

import pymupdf

from extract_figures import CHAPTER_PAGES, CAPTION_RE


def main() -> None:
    pdf_path, images_dir, out_json = sys.argv[1], sys.argv[2], sys.argv[3]
    images_root = Path(images_dir)
    doc = pymupdf.open(pdf_path)
    result: dict[str, list[dict]] = {}
    for ch, (p_start, p_end) in CHAPTER_PAGES.items():
        ch_key = f"ch{ch:02d}"
        seen: set[tuple[int, int]] = set()
        entries: list[dict] = []
        for pno in range(p_start - 1, p_end):
            page = doc[pno]
            for b in page.get_text("blocks"):
                text = b[4].strip()
                m = CAPTION_RE.match(text)
                if not m:
                    continue
                fig_id = (int(m.group(1)), int(m.group(2)))
                if fig_id in seen:
                    continue
                # 只记录已成功剪裁的图
                fname = f"fig{fig_id[0]:02d}_{fig_id[1]:02d}.png"
                if not (images_root / ch_key / fname).exists():
                    continue
                seen.add(fig_id)
                caption = re.sub(r"^Fig(?:ure)?\.?\s*\d+\.\d+\s*", "", text)
                caption = re.sub(r"\s*\n\s*", " ", caption).strip()
                entries.append({
                    "fig": f"{fig_id[0]}.{fig_id[1]}",
                    "file": f"images/{ch_key}/{fname}",
                    "pdf_page": pno + 1,
                    "caption_en": caption,
                })
        entries.sort(key=lambda e: float(e["fig"]))
        result[ch_key] = entries
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    total = sum(len(v) for v in result.values())
    print(f"chapters={len(result)} figures_with_caption={total}")


if __name__ == "__main__":
    main()
