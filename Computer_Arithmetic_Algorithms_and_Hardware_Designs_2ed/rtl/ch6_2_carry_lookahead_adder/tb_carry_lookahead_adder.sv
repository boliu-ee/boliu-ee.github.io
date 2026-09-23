`timescale 1ns/1ps
module tb;
    reg  [15:0] a, b;
    reg         cin;
    wire [15:0] s;
    wire        cout;
    integer errors = 0;
    integer i;

    carry_lookahead_adder dut (.a(a), .b(b), .cin(cin), .s(s), .cout(cout));

    task check;
        input [15:0] ta;
        input [15:0] tb_;
        input        tcin;
        reg [16:0] expected;
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
        check(16'h0000, 16'h0000, 1'b0);
        check(16'h0000, 16'h0000, 1'b1);
        check(16'hFFFF, 16'hFFFF, 1'b1);
        check(16'hFFFF, 16'h0000, 1'b1);   // 全传播
        check(16'h0F0F, 16'h00F0, 1'b1);   // 组间进位
        check(16'hAAAA, 16'h5555, 1'b1);
        check(16'h1234, 16'h4321, 1'b0);
        for (i = 0; i < 2000; i = i + 1) begin
            check($random, $random, $random & 1);
        end
        if (errors == 0) begin
            $display("TEST PASSED: carry_lookahead_adder 16-bit");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
