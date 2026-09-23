// 原书 8.3 节：Wallace 树多操作数压缩
// 8 个 N 位操作数 -> 4 级 CSA 树压成 2 个数 -> 最终 CPA 求和。
// 压缩序列：8 -> 6 -> 4 -> 3 -> 2，树高与 Dadda 相同。
module csa #(parameter W = 12) (
    input  wire [W-1:0] x, y, z,
    output wire [W-1:0] s,
    output wire [W-1:0] c
);
    wire [W-1:0] co;
    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) begin : g_fa
            assign s[i]  = x[i] ^ y[i] ^ z[i];
            assign co[i] = (x[i] & y[i]) | (x[i] & z[i]) | (y[i] & z[i]);
        end
    endgenerate
    assign c = {co[W-2:0], 1'b0};
endmodule

module wallace_tree #(parameter N = 8) (
    input  wire [N-1:0] x0, x1, x2, x3, x4, x5, x6, x7,
    output wire [N+2:0] sum
);
    localparam W = N + 3;   // 容纳 8 个数求和的位宽增长
    // 第 1 级：8 = 3+3+2 -> 2 个 CSA 压 6 个，2 个直传 -> 6 个
    wire [W-1:0] s1a, c1a, s1b, c1b;
    wire [W-1:0] p1a, p1b;
    csa #(.W(W)) l1a (.x({{3{1'b0}}, x0}), .y({{3{1'b0}}, x1}),
                      .z({{3{1'b0}}, x2}), .s(s1a), .c(c1a));
    csa #(.W(W)) l1b (.x({{3{1'b0}}, x3}), .y({{3{1'b0}}, x4}),
                      .z({{3{1'b0}}, x5}), .s(s1b), .c(c1b));
    assign p1a = {{3{1'b0}}, x6};
    assign p1b = {{3{1'b0}}, x7};
    // 第 2 级：6 = 3+3 -> 4 个
    wire [W-1:0] s2a, c2a, s2b, c2b;
    csa #(.W(W)) l2a (.x(s1a), .y(c1a), .z(s1b), .s(s2a), .c(c2a));
    csa #(.W(W)) l2b (.x(c1b), .y(p1a), .z(p1b), .s(s2b), .c(c2b));
    // 第 3 级：4 = 3+1 -> 3 个
    wire [W-1:0] s3, c3;
    csa #(.W(W)) l3  (.x(s2a), .y(c2a), .z(s2b), .s(s3), .c(c3));
    // 第 4 级：3 -> 2 个
    wire [W-1:0] s4, c4;
    csa #(.W(W)) l4  (.x(s3), .y(c3), .z(c2b), .s(s4), .c(c4));
    // 最终进位传播加法（CPA）
    assign sum = s4 + c4;
endmodule
