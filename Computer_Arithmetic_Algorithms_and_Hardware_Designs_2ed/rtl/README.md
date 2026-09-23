# RTL 验证库说明

每个子文件夹对应原书一个小节的核心算法，命名规则：`ch<章号>_<节号>_<算法名>`。

## 文件夹结构

```
chX_Y_<algo>/
├── <algo>.sv          # 可综合 RTL（DUT）
├── tb_<algo>.sv       # 自校验 testbench（顶层模块名恒为 tb）
├── run_iverilog.sh    # Icarus Verilog 一键编译+仿真
└── run_verilator.sh   # Verilator 一键编译+仿真
```

## 使用方法

```bash
cd rtl/chX_Y_<algo>
bash run_iverilog.sh     # Windows 装有 C:\iverilog 时直接可用
bash run_verilator.sh    # 推荐在 Linux / WSL 下使用
```

testbench 约定：

- 通过时打印 `TEST PASSED`，失败时打印 `TEST FAILED` 并以非零码退出；
- 激励采用定向用例 + 随机回归（与黄金模型比对）；
- RTL 均参数化（位宽 `N` 等），默认参数对应书中典型配置。

## 算法清单（16 个，全部通过 iverilog 回归）

| 文件夹 | 对应原书 | 算法 |
|---|---|---|
| ch5_1_ripple_carry_adder | 5.1 | 全加器与行波进位加法器 |
| ch5_5_updown_counter | 5.5 | 加常数：可逆计数器 |
| ch6_2_carry_lookahead_adder | 6.2 | 4 位组两级超前进位加法器 |
| ch6_4_kogge_stone_adder | 6.4/6.5 | Kogge-Stone 与 Brent-Kung 前缀加法器 |
| ch7_1_carry_skip_adder | 7.1 | 进位跳过加法器 |
| ch7_3_carry_select_adder | 7.3 | 进位选择加法器 |
| ch7_4_conditional_sum_adder | 7.4 | 条件和加法器 |
| ch8_2_carry_save_adder | 8.2 | 进位保存加法器与 4 操作数压缩树 |
| ch8_3_wallace_tree | 8.3 | 8 操作数 Wallace 压缩树 |
| ch9_1_shift_add_multiplier | 9.1/9.3 | 移位-加时序乘法器 |
| ch10_2_booth_radix4_multiplier | 10.2 | 改进 Booth 重编码乘法器 |
| ch11_5_array_multiplier | 11.5 | 阵列乘法器 |
| ch13_4_nonrestoring_divider | 13.4 | 不恢复余数除法器 |
| ch18_4_fp_multiplier | 18.4 | 简化 IEEE-754 binary32 浮点乘法器 |
| ch21_2_restoring_sqrt | 21.2 | 恢复式移位/减开平方器 |
| ch22_2_cordic_rotation | 22.2/22.3 | CORDIC 迭代（旋转模式） |
