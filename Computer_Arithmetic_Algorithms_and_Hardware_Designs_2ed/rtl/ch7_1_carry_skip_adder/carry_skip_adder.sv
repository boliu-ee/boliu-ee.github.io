// 原书 7.1 节：进位跳过加法器（Carry-Skip Adder）
// 组内行波；若组内所有 p_i=1（全传播），进位经旁路 mux 直接跳过整组。
module carry_skip_adder #(parameter N = 16, parameter G = 4) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    localparam NG = N / G;   // 组数（N 需被 G 整除）
    wire [NG:0] c;           // 组间进位
    assign c[0] = cin;
    assign cout = c[NG];

    genvar gi, i;
    generate
        for (gi = 0; gi < NG; gi = gi + 1) begin : g_group
            wire [G:0]   cc;      // 组内行波进位
            wire [G-1:0] p;
            wire         pgroup;
            assign cc[0] = c[gi];
            for (i = 0; i < G; i = i + 1) begin : g_bit
                assign p[i]        = a[gi*G+i] ^ b[gi*G+i];
                assign s[gi*G+i]   = p[i] ^ cc[i];
                assign cc[i+1]     = (a[gi*G+i] & b[gi*G+i]) | (p[i] & cc[i]);
            end
            assign pgroup  = &p;                          // 组传播
            assign c[gi+1] = cc[G] | (pgroup & c[gi]);    // 跳过逻辑
        end
    endgenerate
endmodule
