// 原书 10.2 节：改进 Booth 重编码（radix-4 MBE）乘法器
// 有符号 8×8 -> 16 位，组合逻辑：Booth 编码 -> 部分积选择 -> CSA 压缩 -> CPA。
// 部分积集合 {0, ±x, ±2x}，全部来自移位与取补，无"难倍数"。
module booth_radix4_multiplier (
    input  wire signed [7:0]  a,   // 被乘数
    input  wire signed [7:0]  b,   // 乘数
    output wire signed [15:0] p
);
    // ---- 1. Booth 编码：4 个重叠三位窗口，y[-1]=0 ----
    wire [2:0] win [0:3];
    assign win[0] = {b[1], b[0], 1'b0};
    assign win[1] = b[3:1];
    assign win[2] = b[5:3];
    assign win[3] = b[7:5];

    // ---- 2. 部分积生成：按窗口数字从 {0,±x,±2x} 选择并符号扩展到 16 位 ----
    reg signed [15:0] pp [0:3];
    integer i;
    reg signed [15:0] mag;   // |倍数|（移位后零扩展）
    always @* begin
        for (i = 0; i < 4; i = i + 1) begin
            case (win[i])
                3'b000, 3'b111: mag = 16'sd0;                    // 0
                3'b001, 3'b010: mag = {{8{a[7]}}, a};            // +x
                3'b011:         mag = {{7{a[7]}}, a, 1'b0};      // +2x
                3'b100:         mag = {{7{a[7]}}, a, 1'b0};      // -2x（取反在下面）
                default:        mag = {{8{a[7]}}, a};            // -x
            endcase
            // 负倍数：补码取负 = 按位取反 + 1
            if (win[i][2] && win[i] != 3'b111 && win[i] != 3'b000)
                pp[i] = (~mag + 16'sd1) <<< (2*i);
            else
                pp[i] = mag <<< (2*i);
        end
    end

    // ---- 3. CSA 压缩树：4 个部分积 -> 2 行 -> CPA ----
    wire [15:0] s1 = pp[0] ^ pp[1] ^ pp[2];
    wire [15:0] c1 = ((pp[0] & pp[1]) | (pp[0] & pp[2]) | (pp[1] & pp[2])) << 1;
    wire [15:0] s2 = s1 ^ c1 ^ pp[3];
    wire [15:0] c2 = ((s1 & c1) | (s1 & pp[3]) | (c1 & pp[3])) << 1;

    assign p = s2 + c2;   // 最终进位传播加法（16 位截断即正确结果）
endmodule
