// 原书 6.2 节：超前进位加法器（Carry-Lookahead Adder）
// 两级结构：4 位 CLA 组内展开进位递推，组间再用一级 lookahead。
// 延迟 O(log N)，对比行波进位的 O(N)。

// 4 位超前进位组
module cla4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       pg,   // 组传播 P = p3p2p1p0
    output wire       gg    // 组生成 G（不含 cin）
);
    wire [3:0] g, p;
    wire [4:0] c;
    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                | (p[3] & p[2] & p[1] & g[0])
                | (p[3] & p[2] & p[1] & p[0] & c[0]);

    assign s  = p ^ c[3:0];
    assign pg = &p;
    assign gg = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
              | (p[3] & p[2] & p[1] & g[0]);
endmodule

// 16 位两级超前进位加法器
module carry_lookahead_adder (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] s,
    output wire        cout
);
    wire [3:0] pg, gg;
    wire [4:0] c;   // 组间进位

    assign c[0] = cin;
    assign c[1] = gg[0] | (pg[0] & c[0]);
    assign c[2] = gg[1] | (pg[1] & gg[0]) | (pg[1] & pg[0] & c[0]);
    assign c[3] = gg[2] | (pg[2] & gg[1]) | (pg[2] & pg[1] & gg[0])
                | (pg[2] & pg[1] & pg[0] & c[0]);
    assign c[4] = gg[3] | (pg[3] & gg[2]) | (pg[3] & pg[2] & gg[1])
                | (pg[3] & pg[2] & pg[1] & gg[0])
                | (pg[3] & pg[2] & pg[1] & pg[0] & c[0]);
    assign cout = c[4];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_group
            cla4 u_cla4 (
                .a(a[i*4 +: 4]), .b(b[i*4 +: 4]), .cin(c[i]),
                .s(s[i*4 +: 4]), .pg(pg[i]), .gg(gg[i])
            );
        end
    endgenerate
endmodule
