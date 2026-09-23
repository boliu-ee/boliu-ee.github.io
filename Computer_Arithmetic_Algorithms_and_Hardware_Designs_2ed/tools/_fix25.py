import io, os, re

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
p = os.path.join(root, "ch25.qmd")
s = io.open(p, encoding="utf-8").read()

old_head = s[s.index("判据要加严格一点"):s.index("- **数字流水乘法器")]
new_head = (
    "判据还需要加严一条：**任何未经锁存的信号都不允许跨多个单元传播**——否则行波进位加法器也要算"
    "「脉动」了。进位链不经寄存器地横跨整个字宽，所以它不是脉动结构；这一条把「局部性」"
    "从几何要求提升成了时序要求。\n\n"
    "三个值得记住的构造实例：\n\n"
    "- **阵列乘法器 → 位并行脉动乘法器**。图 11.18 的流水阵列乘法器把 $a_i$ 广播给整列、"
    "把 $x_j$ 广播给整行；把广播改成「从前一个 PE 接过来、每拍往下（或往右）传一格」，"
    "同时在其余输入路径上补齐等量延迟，电路功能完全不变——这种变换叫"
    "**脉动重定时（systolic retiming）**。若要求乘积各位同时可用，还要在 $p$ 输出路径上补延迟。\n"
)
s = s.replace(old_head, new_head)

s = s.replace(
    " plethora ển", "")
s = s.replace(
    "脉动版本把**数据与控制一起流水化**——乘法 Ergebnisse 沿链右传、系数载荷沿链左传。",
    "脉动版本把**数据与控制一起流水化**：输入样本沿链一级级右传，系数载荷也随时间戳向前传递，"
    "不再有任何信号需要跨越整个阵列。")
s = s.replace(
    "对视网膜 FIR 做过详细建模：",
    "对可编程 FIR 的两种实现做过详细建模：")
s = s.replace(
    '连线延迟占比越高，" killing zum Localität"这一条的价值就越大；',
    "连线延迟在延迟预算中的占比越高，「通信局部化」这一条的价值就越大；")

io.open(p, "w", encoding="utf-8").write(s)

# sanity: report any suspicious non-CJK/latin scripts left
bad = []
for i, ch in enumerate(s):
    o = ord(ch)
    if 0x1100 <= o <= 0x11FF or 0x0590 <= o <= 0x05FF or 0x0E00 <= o <= 0x0E7F or 0xAC00 <= o <= 0xD7AF:
        bad.append((i, ch))
print("suspicious:", bad[:20])
print("lines:", s.count("\n") + 1)
