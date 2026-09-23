// 原书 13.4 节：不恢复余数除法器（Nonrestoring Divider）
// 无符号 16 位被除数 / 8 位除数 -> 8 位商 + 8 位余数。
// 每拍固定一次加减：部分余数 >= 0 则减除数，否则加除数；
// 商位 = （运算后部分余数 >= 0)。结束时若部分余数为负，加回除数修正。
module nonrestoring_divider (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] z,      // 被除数（高 8 位须 < 除数，保证商 < 256）
    input  wire [7:0]  d,      // 除数（非零）
    output reg  [7:0]  q,
    output reg  [7:0]  r,
    output reg         done
);
    reg signed [8:0] rem;      // 部分余数（带符号，9 位）
    reg [7:0]  quos;           // 商累加（同时充当被除数移位寄存器）
    reg [7:0]  cnt;
    reg        busy;

    wire signed [8:0] rem_shift = {rem[7:0], quos[7]};  // 左移并补入被除数下一位
    wire signed [8:0] rem_next  = (rem >= 0) ? rem_shift - $signed({1'b0, d})
                                             : rem_shift + $signed({1'b0, d});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rem <= 0; quos <= 0; cnt <= 0; busy <= 0;
            q <= 0; r <= 0; done <= 0;
        end else if (start && !busy) begin
            // 被除数高 8 位先入部分余数，低 8 位入商寄存器
            rem  <= $signed({1'b0, z[15:8]});
            quos <= z[7:0];
            cnt  <= 0;
            busy <= 1'b1;
            done <= 1'b0;
        end else if (busy) begin
            rem  <= rem_next;
            quos <= {quos[6:0], (rem_next >= 0)};
            cnt  <= cnt + 1;
            if (cnt == 7) begin
                busy <= 1'b0;
                done <= 1'b1;
                q    <= {quos[6:0], (rem_next >= 0)};
                // 最终修正：部分余数为负则加回除数
                r    <= (rem_next >= 0) ? rem_next[7:0]
                                        : (rem_next + $signed({1'b0, d}));
            end
        end
    end
endmodule
