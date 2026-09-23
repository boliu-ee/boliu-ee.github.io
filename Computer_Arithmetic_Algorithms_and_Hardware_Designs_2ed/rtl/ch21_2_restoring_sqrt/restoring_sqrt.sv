// 原书 21.2 节：恢复式移位/减开平方器（Restoring Shift/Subtract Square-Rooter）
// 无符号 16 位 -> 8 位根 + 余数。每拍出 1 位根：
//   部分余数左移 2 位补入被开方数高 2 位，试减 (4q+1)，
//   够减则根位置 1 并保留差，否则根位置 0 恢复原值。
module restoring_sqrt (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] d,        // 被开方数
    output reg  [7:0]  q,        // 平方根
    output reg  [7:0]  r,        // 余数（d - q*q，最大 2q）
    output reg         done
);
    reg [15:0] rem;              // 部分余数
    reg [15:0] din;              // 被开方数移位寄存器
    reg [7:0]  root;
    reg [3:0]  cnt;
    reg        busy;

    wire [15:0] rem_sh = {rem[13:0], din[15:14]};   // 左移 2 位 + 新 2 位
    wire [15:0] trial  = {6'b0, root, 2'b01};       // 4q + 1

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rem <= 0; din <= 0; root <= 0; cnt <= 0; busy <= 0;
            q <= 0; r <= 0; done <= 0;
        end else if (start && !busy) begin
            rem  <= 0;
            din  <= d;
            root <= 0;
            cnt  <= 0;
            busy <= 1'b1;
            done <= 1'b0;
        end else if (busy) begin
            din <= {din[13:0], 2'b00};
            if (rem_sh >= trial) begin
                rem  <= rem_sh - trial;
                root <= {root[6:0], 1'b1};
            end else begin
                rem  <= rem_sh;
                root <= {root[6:0], 1'b0};
            end
            cnt <= cnt + 1;
            if (cnt == 7) begin
                busy <= 1'b0;
                done <= 1'b1;
                q    <= (rem_sh >= trial) ? {root[6:0], 1'b1} : {root[6:0], 1'b0};
                r    <= (rem_sh >= trial) ? (rem_sh - trial) : rem_sh;
            end
        end
    end
endmodule
