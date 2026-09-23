// 原书 5.1 节：全加器与行波进位加法器（Ripple-Carry Adder）
// 结构：N 个全加器串成进位链，延迟 O(N)，面积最小、最规整。
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire s,
    output wire cout
);
    assign s    = a ^ b ^ cin;
    assign cout = (a & b) | ((a ^ b) & cin);
endmodule

module ripple_carry_adder #(parameter N = 8) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] s,
    output wire         cout
);
    wire [N:0] c;
    assign c[0] = cin;
    assign cout = c[N];
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_fa
            full_adder fa (
                .a(a[i]), .b(b[i]), .cin(c[i]),
                .s(s[i]), .cout(c[i+1])
            );
        end
    endgenerate
endmodule
