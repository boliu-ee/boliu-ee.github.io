import io, os, re, unicodedata

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
files = ["ch25.qmd", "ch26.qmd", "ch27.qmd", "ch28.qmd", "appendix.qmd"]

def safe(ch):
    o = ord(ch)
    if ch in "\n\r\t":
        return True
    if 0x20 <= o <= 0x7E:          # ASCII printable
        return True
    if 0x4E00 <= o <= 0x9FFF:      # CJK ideographs
        return True
    if 0x3000 <= o <= 0x303F:      # CJK punctuation
        return True
    if 0xFF00 <= o <= 0xFFEF:      # fullwidth forms
        return True
    if ch in "‘’“”…—·×°≈≤≥∈⊕⊖⌈⌉√∞∑∏√⨯→←↑↓±∨∧¬⊕⊗≡≈≠≡⊂⊃∈∏±∓":
        return True
    if 0x2190 <= o <= 0x21FF or 0x2200 <= o <= 0x22FF or 0x0391 <= o <= 0x03C9:
        return True
    return False

out = []
for f in files:
    p = os.path.join(root, f)
    if not os.path.exists(p):
        continue
    lines = io.open(p, encoding="utf-8").read().split("\n")
    for i, ln in enumerate(lines, 1):
        bad = [(j, ch) for j, ch in enumerate(ln) if not safe(ch)]
        if bad:
            for j, ch in bad:
                out.append("%s:%d: U+%04X %s | %s" % (f, i, ord(ch), repr(ch), ln[max(0,j-25):j+25]))
io.open(os.path.join(root, "tools", "_caps_out.txt"), "w", encoding="utf-8").write("\n".join(out) or "CLEAN")
