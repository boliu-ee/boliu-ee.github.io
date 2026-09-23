// 原书 18.4 节：简化 IEEE-754 binary32 浮点乘法器（教学版）
// 功能：符号异或、阶码相加去偏置、24x24 尾数相乘、规格化、
//       guard/round/sticky 三比特驱动就近偶舍入（RNE）。
// 限制（教学简化）：仅处理规格化数与 ±0；不处理非规格化数、Inf、NaN；
//                   上溢时输出饱和最大规格数，下溢时刷为 ±0。
module fp_multiplier (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] p
);
    wire        sa = a[31], sb = b[31];
    wire [7:0]  ea = a[30:23], eb = b[30:23];
    wire [23:0] ma = {1'b1, a[22:0]};   // 还原隐藏位
    wire [23:0] mb = {1'b1, b[22:0]};

    wire        sp = sa ^ sb;
    wire [47:0] mprod = ma * mb;        // 24x24 -> 48 位

    // 规格化：乘积落在 [1,4)，即第 47 或 46 位为隐藏位
    wire        norm_shift = mprod[47];
    wire [47:0] mnorm = norm_shift ? mprod : (mprod << 1);
    wire signed [9:0] eprod = $signed({2'b0, ea}) + $signed({2'b0, eb})
                              - 10'sd127 + (norm_shift ? 10'sd1 : 10'sd0);

    // RNE 三比特：guard=mnorm[23], round=mnorm[22], sticky=|mnorm[21:0]
    wire        guard  = mnorm[23];
    wire        round  = mnorm[22];
    wire        sticky = |mnorm[21:0];
    wire        round_up = guard & (round | sticky | mnorm[24]);
    wire [24:0] mround = {1'b0, mnorm[47:24]} + (round_up ? 25'd1 : 25'd0);

    // 舍入可能再次进位（如 1.111...1 + ulp = 10.0），需右移一位并阶码 +1
    wire        re_norm = mround[24];
    wire [22:0] mantissa = re_norm ? mround[23:1] : mround[22:0];
    wire signed [9:0] efinal = eprod + (re_norm ? 10'sd1 : 10'sd0);

    localparam [9:0] EMAX_SAT = 10'd254;   // 饱和阶码（教学版用最大规格数代替 Inf）

    always @* begin
        if (ea == 0 || eb == 0) begin
            p = {sp, 31'b0};                       // 任何零操作数 -> ±0
        end else if (efinal >= $signed(EMAX_SAT + 1)) begin
            p = {sp, 8'hFE, 23'h7FFFFF};           // 上溢 -> 饱和
        end else if (efinal <= 0) begin
            p = {sp, 31'b0};                       // 下溢 -> 刷零（无非规格化）
        end else begin
            p = {sp, efinal[7:0], mantissa};
        end
    end
endmodule
