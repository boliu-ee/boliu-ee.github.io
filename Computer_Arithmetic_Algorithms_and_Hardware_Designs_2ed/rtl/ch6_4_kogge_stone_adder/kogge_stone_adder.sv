// 原书 6.4/6.5 节：进位确定即并行前缀计算
// Kogge-Stone 前缀加法器：log2(N) 级，每级合并距离 2^j 的 (G,P)。
// 前缀算子：(g,p) . (g',p') = (g + p*g', p*p')
module kogge_stone_adder #(parameter N = 16) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    localparam L = $clog2(N);
    // 各级 (G, P)，第 0 级为位级 g/p
    wire [N-1:0] G [0:L];
    wire [N-1:0] P [0:L];

    genvar i, j;

    // 位级：bit0 吸收 cin
    assign G[0][0] = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin);
    assign P[0][0] = 1'b0;
    generate
        for (i = 1; i < N; i = i + 1) begin : g_init
            assign G[0][i] = a[i] & b[i];
            assign P[0][i] = a[i] ^ b[i];
        end
        // 前缀级
        for (j = 1; j <= L; j = j + 1) begin : g_stage
            for (i = 0; i < N; i = i + 1) begin : g_node
                if (i >= (1 << (j-1))) begin : g_merge
                    assign G[j][i] = G[j-1][i] |
                        (P[j-1][i] & G[j-1][i - (1 << (j-1))]);
                    assign P[j][i] = P[j-1][i] & P[j-1][i - (1 << (j-1))];
                end else begin : g_pass
                    assign G[j][i] = G[j-1][i];
                    assign P[j][i] = P[j-1][i];
                end
            end
        end
    endgenerate

    // 进位：c[i] = G[L][i-1]（i>=1），c[0]=cin；和位 s = p ^ c
    wire [N-1:0] p_bit = a ^ b;
    assign s[0] = p_bit[0] ^ cin;
    generate
        for (i = 1; i < N; i = i + 1) begin : g_sum
            assign s[i] = p_bit[i] ^ G[L][i-1];
        end
    endgenerate
    assign cout = G[L][N-1];
endmodule
