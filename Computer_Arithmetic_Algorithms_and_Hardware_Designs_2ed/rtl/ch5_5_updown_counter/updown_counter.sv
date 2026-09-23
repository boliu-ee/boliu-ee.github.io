// 原书 5.5 节：加常数的特化——可逆计数器（Up/Down Counter）
// 加 1 / 减 1 是"一个操作数为常数"的退化加法，硬件约为全加器一半。
module updown_counter #(parameter N = 8) (
    input  wire         clk,
    input  wire         rst_n,   // 低有效异步复位
    input  wire         en,      // 计数使能
    input  wire         up,      // 1=加 1，0=减 1
    input  wire         load,    // 同步加载（优先级高于 en）
    input  wire [N-1:0] din,
    output reg  [N-1:0] q,
    output wire         carry,   // 上溢（up 且 q 全 1）
    output wire         borrow   // 下溢（down 且 q 全 0）
);
    assign carry  = en & up  & (&q);
    assign borrow = en & ~up & (~|q);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= {N{1'b0}};
        else if (load)
            q <= din;
        else if (en)
            q <= up ? (q + 1'b1) : (q - 1'b1);
    end
endmodule
