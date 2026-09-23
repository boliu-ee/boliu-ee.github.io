`timescale 1ns/1ps
module tb;
    localparam N = 8;
    reg  [N-1:0] x0, x1, x2, x3, x4, x5, x6, x7;
    wire [N+2:0] sum;
    integer errors = 0;
    integer i;

    wallace_tree #(.N(N)) dut (
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .x4(x4), .x5(x5), .x6(x6), .x7(x7), .sum(sum)
    );

    task check;
        input [N-1:0] t0, t1, t2, t3, t4, t5, t6, t7;
        reg [N+2:0] expected;
        begin
            x0=t0; x1=t1; x2=t2; x3=t3; x4=t4; x5=t5; x6=t6; x7=t7;
            #1;
            expected = t0 + t1 + t2 + t3 + t4 + t5 + t6 + t7;
            if (sum !== expected) begin
                errors = errors + 1;
                $display("ERROR: %h+%h+%h+%h+%h+%h+%h+%h -> %h, expected %h",
                         t0, t1, t2, t3, t4, t5, t6, t7, sum, expected);
            end
        end
    endtask

    initial begin
        check(0, 0, 0, 0, 0, 0, 0, 0);
        check(8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF); // 2040
        check(1, 2, 4, 8, 16, 32, 64, 128);
        check(8'hAA, 8'h55, 8'hAA, 8'h55, 8'hAA, 8'h55, 8'hAA, 8'h55);
        for (i = 0; i < 3000; i = i + 1) begin
            check($random, $random, $random, $random,
                  $random, $random, $random, $random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: wallace_tree 8x%0d-bit", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
