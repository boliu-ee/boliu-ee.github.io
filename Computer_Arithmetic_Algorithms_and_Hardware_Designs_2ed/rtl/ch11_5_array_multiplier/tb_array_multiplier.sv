`timescale 1ns/1ps
module tb;
    localparam N = 8;
    reg  [N-1:0] a, b;
    wire [2*N-1:0] p;
    integer errors = 0;
    integer i;

    array_multiplier #(.N(N)) dut (.a(a), .b(b), .p(p));

    task check;
        input [N-1:0] ta;
        input [N-1:0] tb_;
        reg [2*N-1:0] expected;
        begin
            a = ta; b = tb_;
            #1;
            expected = ta * tb_;
            if (p !== expected) begin
                errors = errors + 1;
                $display("ERROR: %0d * %0d -> %0d, expected %0d",
                         ta, tb_, p, expected);
            end
        end
    endtask

    initial begin
        check(0, 0);
        check(1, 1);
        check(8'hFF, 8'hFF);
        check(8'h80, 8'h02);
        check(8'hAA, 8'h55);
        check(8'd13, 8'd17);
        check(8'h01, 8'hFF);
        for (i = 0; i < 2000; i = i + 1) begin
            check($random, $random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: array_multiplier N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
