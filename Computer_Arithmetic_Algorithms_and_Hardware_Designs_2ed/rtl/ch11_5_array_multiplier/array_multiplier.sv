// 原书 11.5 节：阵列乘法器（Array Multiplier）
// 无符号 N×N -> 2N 位。部分积按行斜向对齐，行间用全加器链逐级累加，
// 结构极度规整（同一 FA 单元平铺），延迟 O(N)，胜在版图规则。
module array_multiplier #(parameter N = 8) (
    input  wire [N-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [2*N-1:0] p
);
    // rowsum[i] = 前 i+1 个部分积的累计和（2N 位）
    wire [2*N-1:0] rowsum [0:N];
    wire [2*N-1:0] pp     [0:N-1];

    genvar i, j;
    generate
        // 第 i 个部分积：a * b[i]，左移 i 位
        for (i = 0; i < N; i = i + 1) begin : g_pp
            assign pp[i] = ({{N{1'b0}}, a} & {2*N{b[i]}}) << i;
        end
        assign rowsum[0] = {2*N{1'b0}};
        // 逐行累加：每行一个 2N 位行波加法器（FA 阵列的一行）
        for (i = 0; i < N; i = i + 1) begin : g_row
            wire [2*N:0] c;
            assign c[0] = 1'b0;
            for (j = 0; j < 2*N; j = j + 1) begin : g_fa
                assign rowsum[i+1][j] = rowsum[i][j] ^ pp[i][j] ^ c[j];
                assign c[j+1] = (rowsum[i][j] & pp[i][j]) |
                                ((rowsum[i][j] ^ pp[i][j]) & c[j]);
            end
        end
    endgenerate
    assign p = rowsum[N];
endmodule
