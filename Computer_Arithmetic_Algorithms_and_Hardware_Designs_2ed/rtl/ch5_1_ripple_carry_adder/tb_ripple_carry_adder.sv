`timescale 1ns/1ps
// 自校验 testbench：定向用例 + 随机回归，与黄金模型比对
module tb;
    localparam N = 16;
    reg  [N-1:0] a, b;
    reg          cin;
    wire [N-1:0] s;
    wire         cout;
    integer errors = 0;
    integer i;

    ripple_carry_adder #(.N(N)) dut (
        .a(a), .b(b), .cin(cin), .s(s), .cout(cout)
    );

    task check;
        input [N-1:0] ta;
        input [N-1:0] tb_;
        input         tcin;
        reg [N:0] expected;
        begin
            a = ta; b = tb_; cin = tcin;
            #1;
            expected = {1'b0, ta} + {1'b0, tb_} + tcin;
            if ({cout, s} !== expected) begin
                errors = errors + 1;
                $display("ERROR: a=%h b=%h cin=%b -> got %h, expected %h",
                         ta, tb_, tcin, {cout, s}, expected);
            end
        end
    endtask

    initial begin
        // 定向：全 0 / 全 1 / 进位链全传播 / 交替模式
        check({N{1'b0}}, {N{1'b0}}, 1'b0);
        check({N{1'b0}}, {N{1'b0}}, 1'b1);
        check({N{1'b1}}, {N{1'b1}}, 1'b0);
        check({N{1'b1}}, {N{1'b1}}, 1'b1);
        check({N{1'b1}}, {N{1'b0}}, 1'b1);   // 最长进位传播
        check(16'hAAAA, 16'h5555, 1'b0);
        check(16'hAAAA, 16'h5555, 1'b1);
        check(16'h8000, 16'h8000, 1'b0);
        // 随机回归
        for (i = 0; i < 2000; i = i + 1) begin
            check($random, $random, $random & 1);
        end
        if (errors == 0) begin
            $display("TEST PASSED: ripple_carry_adder N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
