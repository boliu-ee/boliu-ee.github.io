// 原书 22.2/22.3 节：CORDIC 迭代（旋转模式，rotation mode）
// 定点 Q2.14（1 符号 + 1 整数 + 14 小数），12 级迭代。
// 输入角度 z（弧度 * 2^14，范围 ±pi/2），输出 cos/sin（* 2^14）。
// 每拍：d = sign(z)；x' = x - d*(y>>>i)；y' = y + d*(x>>>i)；z' = z - d*atan[i]。
module cordic_rotation (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire signed [15:0] angle,   // z0，Q2.14
    output reg  signed [15:0] cos_o,   // Q2.14
    output reg  signed [15:0] sin_o,   // Q2.14
    output reg                done
);
    // atan(2^-i) * 2^14，i = 0..11
    reg signed [15:0] atan_tab [0:11];
    initial begin
        atan_tab[0]  = 16'd12867;  // 0.785398
        atan_tab[1]  = 16'd7596;   // 0.463648
        atan_tab[2]  = 16'd4014;   // 0.244979
        atan_tab[3]  = 16'd2038;   // 0.124355
        atan_tab[4]  = 16'd1023;   // 0.062419
        atan_tab[5]  = 16'd512;    // 0.031240
        atan_tab[6]  = 16'd256;    // 0.015624
        atan_tab[7]  = 16'd128;    // 0.007812
        atan_tab[8]  = 16'd64;     // 0.003906
        atan_tab[9]  = 16'd32;     // 0.001953
        atan_tab[10] = 16'd16;     // 0.000977
        atan_tab[11] = 16'd8;      // 0.000488
    end

    localparam signed [15:0] K = 16'd9949;   // CORDIC 增益倒数 0.607253 * 2^14

    reg signed [15:0] x, y, z;
    reg [3:0]  i;
    reg        busy;

    wire        dir = (z >= 0);   // 旋转方向
    wire signed [15:0] x_next = dir ? x - (y >>> i) : x + (y >>> i);
    wire signed [15:0] y_next = dir ? y + (x >>> i) : y - (x >>> i);
    wire signed [15:0] z_next = dir ? z - atan_tab[i] : z + atan_tab[i];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0; y <= 0; z <= 0; i <= 0; busy <= 0;
            cos_o <= 0; sin_o <= 0; done <= 0;
        end else if (start && !busy) begin
            x <= K; y <= 0; z <= angle;
            i <= 0; busy <= 1'b1; done <= 1'b0;
        end else if (busy) begin
            x <= x_next; y <= y_next; z <= z_next;
            i <= i + 1;
            if (i == 11) begin
                busy  <= 1'b0;
                done  <= 1'b1;
                cos_o <= x_next;
                sin_o <= y_next;
            end
        end
    end
endmodule
