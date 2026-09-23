// 原书 7.4 节：条件和加法器（Conditional-Sum Adder）
// 思想：carry-select 递归到底。第 0 层逐位生成 (cin=0 / cin=1) 两组候选，
// 之后每合并一层块宽加倍、候选减半，log2(N) 层后按真实 cin 选取。
module conditional_sum_adder #(parameter N = 16) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    localparam L = $clog2(N);

    // sum0/st、car0/1：第 st 层、块起始位索引处存放该块的候选和与候选进位出
    wire [N-1:0] sum0 [0:L];
    wire [N-1:0] sum1 [0:L];
    wire [N-1:0] car0 [0:L];
    wire [N-1:0] car1 [0:L];

    genvar i, st, bk;

    // 第 0 层：位级候选
    generate
        for (i = 0; i < N; i = i + 1) begin : g_lvl0
            assign sum0[0][i] = a[i] ^ b[i];          // cin=0 的和
            assign car0[0][i] = a[i] & b[i];          // cin=0 的进位出
            assign sum1[0][i] = ~(a[i] ^ b[i]);       // cin=1 的和
            assign car1[0][i] = a[i] | b[i];          // cin=1 的进位出
        end
    endgenerate

    // 第 st 层（块宽 2^st）：低半块进位选择高半块候选
    generate
        for (st = 1; st <= L; st = st + 1) begin : g_lvl
            for (bk = 0; bk < N / (1 << st); bk = bk + 1) begin : g_blk
                localparam int W  = 1 << st;          // 块宽
                localparam int H  = W >> 1;           // 半块宽
                localparam int LO = bk * W;           // 低半块起始
                localparam int HI = bk * W + H;       // 高半块起始
                // cin=0 分支
                assign sum0[st][LO +: W] =
                    {car0[st-1][LO] ? sum1[st-1][HI +: H]
                                    : sum0[st-1][HI +: H],
                     sum0[st-1][LO +: H]};
                assign car0[st][LO] =
                    car0[st-1][LO] ? car1[st-1][HI] : car0[st-1][HI];
                // cin=1 分支
                assign sum1[st][LO +: W] =
                    {car1[st-1][LO] ? sum1[st-1][HI +: H]
                                    : sum0[st-1][HI +: H],
                     sum1[st-1][LO +: H]};
                assign car1[st][LO] =
                    car1[st-1][LO] ? car1[st-1][HI] : car0[st-1][HI];
            end
        end
    endgenerate

    assign s    = cin ? sum1[L] : sum0[L];
    assign cout = cin ? car1[L][0] : car0[L][0];
endmodule
