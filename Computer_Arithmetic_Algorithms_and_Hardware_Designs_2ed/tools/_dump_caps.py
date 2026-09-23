import os, fitz
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pdf = os.path.join(os.path.dirname(root),
    "Computer_Arithmetic_Algorithms_and_Hardware_Designs_second_edition_(Behrooz_Parhami).pdf")
doc = fitz.open(pdf)

# json pdf_page P  ->  0-based index i = P - 1
def dump(p0, p1, outfile):
    parts = []
    for P in range(p0, p1 + 1):
        i = P - 1
        if 0 <= i < doc.page_count:
            parts.append("<<<JP%d>>>" % P)
            parts.append(doc[i].get_text())
    open(os.path.join(root, "tools", outfile), "w", encoding="utf-8").write("\n".join(parts))

dump(580, 596, "_txt_ch27.txt")
dump(601, 618, "_txt_ch28.txt")
dump(622, 636, "_txt_app.txt")
