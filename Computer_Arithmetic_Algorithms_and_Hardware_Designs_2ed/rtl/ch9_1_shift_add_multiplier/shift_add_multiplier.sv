// 原书 9.1/9.3 节：移位-加时序乘法器（Shift/Add Sequential Multiplier）
// 无符号 N×N -> 2N 位。累加器高 N 位与乘数寄存器低 N 位串联，
// 每拍：若乘数最低位为 1 则加被乘数，整体右移一位；N 拍完成。
module shift_add_multiplier #(parameter N = 8) (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           start,     // 高电平一拍，加载并开始
    input  wire [N-1:0]   a,         // 被乘数
    input  wire [N-1:0]   b,         // 乘数
    output reg  [2*N-1:0] p,         // 乘积
    output reg            done
);
    reg  [2*N-1:0] acc;              // {部分积, 乘数}
    reg  [N-1:0]   mcand;
    reg  [7:0]     cnt;
    reg            busy;
    wire [N:0]     addend  = acc[0] ? {1'b0, mcand} : {N+1{1'b0}};
    wire [N:0]     sum     = {1'b0, acc[2*N-1:N]} + addend;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= 0; mcand <= 0; cnt <= 0; busy <= 0; p <= 0; done <= 0;
        end else if (start && !busy) begin
            acc   <= {{N{1'b0}}, b};
            mcand <= a;
            cnt   <= 0;
            busy  <= 1'b1;
            done  <= 1'b0;
        end else if (busy) begin
            acc <= {sum, acc[N-1:1]};   // 条件加后整体右移
            cnt <= cnt + 1;
            if (cnt == N-1) begin
                busy <= 1'b0;
                done <= 1'b1;
                p    <= {sum, acc[N-1:1]};
            end
        end
    end
endmodule
