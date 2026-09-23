// 原书 7.3 节：进位选择加法器（Carry-Select Adder）
// 每组并行计算 cin=0 与 cin=1 两份结果，真实进位到达后 mux 选择。
module carry_select_adder #(parameter N = 16, parameter G = 4) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    localparam NG = N / G;
    wire [NG:0] c;
    assign c[0] = cin;
    assign cout = c[NG];

    genvar gi;
    generate
        for (gi = 0; gi < NG; gi = gi + 1) begin : g_group
            wire [G-1:0] s0, s1;
            wire         c0, c1;
            assign {c0, s0} = {1'b0, a[gi*G +: G]} + {1'b0, b[gi*G +: G]};
            assign {c1, s1} = {1'b0, a[gi*G +: G]} + {1'b0, b[gi*G +: G]}
                              + {{G{1'b0}}, 1'b1};
            assign s[gi*G +: G] = c[gi] ? s1 : s0;
            assign c[gi+1]      = c[gi] ? c1 : c0;
        end
    endgenerate
endmodule
