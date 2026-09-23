`timescale 1ns/1ps
module tb;
    localparam N = 16;
    reg  [N-1:0] a, b;
    reg          cin;
    wire [N-1:0] s;
    wire         cout;
    integer errors = 0;
    integer i;

    carry_select_adder #(.N(N), .G(4)) dut (
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
        check({N{1'b0}}, {N{1'b0}}, 1'b0);
        check({N{1'b0}}, {N{1'b0}}, 1'b1);
        check({N{1'b1}}, {N{1'b1}}, 1'b1);
        check({N{1'b1}}, {N{1'b0}}, 1'b1);
        check(16'hAAAA, 16'h5555, 1'b0);
        check(16'h0FFF, 16'h0001, 1'b0);   // 组内全传播进位
        check(16'h00F0, 16'h00F0, 1'b1);
        for (i = 0; i < 2000; i = i + 1) begin
            check($random, $random, $random & 1);
        end
        if (errors == 0) begin
            $display("TEST PASSED: carry_select_adder N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
