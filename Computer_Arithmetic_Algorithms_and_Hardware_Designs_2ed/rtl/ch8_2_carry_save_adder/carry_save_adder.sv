// 原书 8.2 节：进位保存加法器（Carry-Save Adder, CSA）
// N 个独立全加器：3 个 N 位输入 -> 伪和 s 与左移对齐的进位 c。
// 完整恒等式：x + y + z == s + c + (cout << N)（无进位传播，延迟 O(1)）。
module carry_save_adder #(parameter N = 8) (
    input  wire [N-1:0] x,
    input  wire [N-1:0] y,
    input  wire [N-1:0] z,
    output wire [N-1:0] s,
    output wire [N-1:0] c,     // 已左移一位对齐权重，c[0]=0
    output wire         cout   // 最高位进位（权重 2^N）
);
    wire [N-1:0] cout_bit;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_fa
            assign s[i]        = x[i] ^ y[i] ^ z[i];
            assign cout_bit[i] = (x[i] & y[i]) | (x[i] & z[i]) | (y[i] & z[i]);
        end
    endgenerate
    assign c    = {cout_bit[N-2:0], 1'b0};
    assign cout = cout_bit[N-1];
endmodule

// 4 操作数压缩树示例：两级 CSA + 一次完整加法（CPA）
module csa_tree4 #(parameter N = 8) (
    input  wire [N-1:0] x0, x1, x2, x3,
    output wire [N+1:0] sum
);
    wire [N+1:0] s1, c1, s2, c2;
    // 零扩展到 N+2 位，容纳进位增长
    carry_save_adder #(.N(N+2)) csa1 (
        .x({2'b0, x0}), .y({2'b0, x1}), .z({2'b0, x2}),
        .s(s1), .c(c1), .cout()   // 树内不会溢出，最高位进位悬空
    );
    carry_save_adder #(.N(N+2)) csa2 (
        .x(s1), .y(c1), .z({2'b0, x3}),
        .s(s2), .c(c2), .cout()
    );
    assign sum = s2 + c2;   // 最终进位传播加法（CPA）
endmodule
