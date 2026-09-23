// 原书 6.5 节：Brent-Kung 前缀加法器
// 2*log2(N)-1 级，节点数最少（约 2N），扇出小，面积/功耗友好。
module brent_kung_adder #(parameter N = 16) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    localparam L = $clog2(N);
    // 共 2L-1 个前缀级（索引 0 为位级，1..L 前向，L+1..2L-1 反向）
    wire [N-1:0] G [0:2*L-1];
    wire [N-1:0] P [0:2*L-1];

    genvar i, st;

    assign G[0][0] = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin);
    assign P[0][0] = 1'b0;
    generate
        for (i = 1; i < N; i = i + 1) begin : g_init
            assign G[0][i] = a[i] & b[i];
            assign P[0][i] = a[i] ^ b[i];
        end

        // 前向归约级 st=1..L：距离 d=2^(st-1)，作用于 (i+1) % 2^st == 0 的位
        for (st = 1; st <= L; st = st + 1) begin : g_fwd
            for (i = 0; i < N; i = i + 1) begin : g_node
                if (((i + 1) % (1 << st)) == 0) begin : g_merge
                    assign G[st][i] = G[st-1][i] |
                        (P[st-1][i] & G[st-1][i - (1 << (st-1))]);
                    assign P[st][i] = P[st-1][i] & P[st-1][i - (1 << (st-1))];
                end else begin : g_pass
                    assign G[st][i] = G[st-1][i];
                    assign P[st][i] = P[st-1][i];
                end
            end
        end

        // 反向扩展级 st=L+1..2L-1：对应距离 d=2^(2L-st-1)
        // 作用于 (i+1) % 2^(2L-st+1) == 2^(2L-st) 的位
        for (st = L + 1; st <= 2*L - 1; st = st + 1) begin : g_bwd
            for (i = 0; i < N; i = i + 1) begin : g_node
                if (((i + 1) % (1 << (2*L - st))) == (1 << (2*L - st - 1))) begin : g_merge
                    assign G[st][i] = G[st-1][i] |
                        (P[st-1][i] & G[st-1][i - (1 << (2*L - st - 1))]);
                    assign P[st][i] = P[st-1][i] & P[st-1][i - (1 << (2*L - st - 1))];
                end else begin : g_pass
                    assign G[st][i] = G[st-1][i];
                    assign P[st][i] = P[st-1][i];
                end
            end
        end
    endgenerate

    wire [N-1:0] p_bit = a ^ b;
    assign s[0] = p_bit[0] ^ cin;
    generate
        for (i = 1; i < N; i = i + 1) begin : g_sum
            assign s[i] = p_bit[i] ^ G[2*L-1][i-1];
        end
    endgenerate
    assign cout = G[2*L-1][N-1];
endmodule
