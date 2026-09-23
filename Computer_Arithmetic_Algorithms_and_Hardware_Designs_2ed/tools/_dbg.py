import io, os

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
p = os.path.join(root, "ch28.qmd")
lines = io.open(p, encoding="utf-8").read().split("\n")
out = []
for n in (65, 83, 85, 121, 107):
    out.append("L%d: %s" % (n, lines[n-1]))
io.open(os.path.join(root, "tools", "_dbg.txt"), "w", encoding="utf-8").write(
    "\n\n".join("C=%r" % c for c in lines[64])[:2000])
