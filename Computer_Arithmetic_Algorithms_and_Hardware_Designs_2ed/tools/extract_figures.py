# -*- coding: utf-8 -*-
"""从原书 PDF 中按图题（Fig. x.y）定位并剪裁插图为 PNG。

原理：正文中插图位于两个文字块之间、图题（Fig. x.y ...）位于插图下方。
对每一页：
  1. 取所有文字块，找出以 Fig./Figure 开头的图题块；
  2. 图题上方到「上一个文字块下沿」（或页面上缘/上一图题上缘）之间的区域即为插图；
  3. 以 2x 缩放渲染该区域为 PNG。

用法：
    python extract_figures.py <pdf_path> <out_dir> [chapters...]
例如：
    python extract_figures.py book.pdf ../images 5 6
不指定章节则处理全部章节。
"""
import re
import sys
from pathlib import Path

import pymupdf

# 各章 PDF 页码范围（1-based，含端点），来自 PDF 书签目录
CHAPTER_PAGES = {
    1: (23, 44), 2: (45, 63), 3: (64, 85), 4: (86, 108),
    5: (110, 130), 6: (131, 151), 7: (152, 174), 8: (175, 194),
    9: (196, 214), 10: (215, 232), 11: (233, 256), 12: (257, 280),
    13: (282, 307), 14: (308, 329), 15: (330, 348), 16: (349, 365),
    17: (367, 390), 18: (391, 411), 19: (412, 430), 20: (431, 451),
    21: (453, 473), 22: (474, 493), 23: (494, 513), 24: (514, 534),
    25: (536, 558), 26: (559, 579), 27: (580, 600), 28: (601, 621),
    29: (622, 641),  # 附录
}

CAPTION_RE = re.compile(r"^\s*(?:Fig(?:ure)?\.?)\s+(\d+)\.(\d+)")
MIN_FIG_HEIGHT = 40   # 过小的区域视为误判
MIN_FIG_WIDTH = 100
MARGIN = 6            # 剪裁留白
ZOOM = 2.0
BODY_X = 115          # 正文栏左边界（左边栏图题 x0 < 此值）
BODY_MIN_W = 300      # 正文段落最小宽度（用于区分图内小标签）


def _page_bands(page):
    """返回 [(cap_rect, fig_id, clip_rect), ...]。

    原书版式：图题或在左边栏（与图横向对齐），或在正文栏图的正下方。
    插图区域 = 上下相邻「边界块」（正文段落/图题/页眉页脚）之间的竖直带。
    """
    blocks = page.get_text("blocks")
    blocks = sorted(blocks, key=lambda b: (b[1], b[0]))
    boundaries, captions = [], []
    for b in blocks:
        r = pymupdf.Rect(b[:4])
        text = b[4].strip()
        m = CAPTION_RE.match(text)
        is_header_footer = r.y1 < 60 or r.y0 > page.rect.height - 40
        is_body_para = r.x0 >= BODY_X and r.width >= BODY_MIN_W
        if m:
            captions.append((r, m))
            boundaries.append(r)
        elif is_header_footer or is_body_para:
            boundaries.append(r)
    results = []
    try:
        drawings = page.get_drawings()
    except Exception:
        drawings = []
    images = page.get_image_info()
    for cap_rect, m in captions:
        top = 0.0
        for r in boundaries:
            if r is not cap_rect and r.y1 <= cap_rect.y0 + 2:
                top = max(top, r.y1)
        if cap_rect.x0 >= BODY_X:
            # 正文栏图题：图在题上方，底部含图题本身
            bottom = cap_rect.y1 + 4
        else:
            # 边栏图题：底部取下一个边界块上沿
            bottom = page.rect.height
            for r in boundaries:
                if r is not cap_rect and r.y0 >= cap_rect.y1 - 2:
                    bottom = min(bottom, r.y0)
        clip = pymupdf.Rect(
            BODY_X - 3,
            max(0, top + 2 - MARGIN),
            page.rect.width - 20,
            min(page.rect.height, bottom + MARGIN),
        )
        # 过滤误判：插图区域内必须有一定数量的矢量图形或位图
        n_draw = sum(1 for d in drawings if pymupdf.Rect(d["rect"]).intersects(clip))
        n_img = sum(1 for im in images if pymupdf.Rect(im["bbox"]).intersects(clip))
        if n_draw < 3 and n_img < 1:
            continue
        fig_id = (int(m.group(1)), int(m.group(2)))
        results.append((cap_rect, fig_id, clip))
    return results


def extract(pdf_path: str, out_root: Path, chapters: list[int]) -> list[dict]:
    doc = pymupdf.open(pdf_path)
    manifest = []
    for ch in chapters:
        p_start, p_end = CHAPTER_PAGES[ch]
        out_dir = out_root / f"ch{ch:02d}"
        out_dir.mkdir(parents=True, exist_ok=True)
        seen: set[tuple[int, int]] = set()
        for pno in range(p_start - 1, p_end):
            page = doc[pno]
            for _, fig_id, clip in _page_bands(page):
                if clip.height < MIN_FIG_HEIGHT or clip.width < MIN_FIG_WIDTH:
                    continue
                if fig_id in seen:  # 同一图号只取首次出现
                    continue
                seen.add(fig_id)
                fname = f"fig{fig_id[0]:02d}_{fig_id[1]:02d}.png"
                out_path = out_dir / fname
                pix = page.get_pixmap(matrix=pymupdf.Matrix(ZOOM, ZOOM), clip=clip)
                pix.save(str(out_path))
                manifest.append({
                    "chapter": ch, "figure": f"{fig_id[0]}.{fig_id[1]}",
                    "pdf_page": pno + 1, "file": f"images/ch{ch:02d}/{fname}",
                })
                print(f"ch{ch:02d} Fig.{fig_id[0]}.{fig_id[1]} p{pno + 1} -> {fname}")
    return manifest


def main() -> None:
    pdf_path = sys.argv[1]
    out_root = Path(sys.argv[2])
    chapters = [int(c) for c in sys.argv[3:]] or sorted(CHAPTER_PAGES)
    extract(pdf_path, out_root, chapters)


if __name__ == "__main__":
    main()
