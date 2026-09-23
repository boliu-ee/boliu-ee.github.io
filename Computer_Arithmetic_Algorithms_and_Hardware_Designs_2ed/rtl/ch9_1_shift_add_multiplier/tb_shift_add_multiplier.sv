`timescale 1ns/1ps
module tb;
    localparam N = 8;
    reg           clk = 0, rst_n = 0, start = 0;
    reg  [N-1:0]  a, b;
    wire [2*N-1:0] p;
    wire          done;
    integer errors = 0;
    integer i;

    shift_add_multiplier #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .a(a), .b(b), .p(p), .done(done)
    );

    always #5 clk = ~clk;

    task check;
        input [N-1:0] ta;
        input [N-1:0] tb_;
        reg [2*N-1:0] expected;
        begin
            @(negedge clk);
            a = ta; b = tb_; start = 1;
            @(negedge clk);
            start = 0;
            wait (done);
            @(negedge clk);
            expected = ta * tb_;
            if (p !== expected) begin
                errors = errors + 1;
                $display("ERROR: %0d * %0d -> %0d, expected %0d",
                         ta, tb_, p, expected);
            end
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst_n = 1;
        check(0, 0);
        check(1, 1);
        check(8'hFF, 8'hFF);   // 255*255 = 65025
        check(8'hFF, 8'h01);
        check(8'h80, 8'h80);
        check(8'hAA, 8'h55);
        check(8'd13, 8'd17);
        for (i = 0; i < 500; i = i + 1) begin
            check($random, $random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: shift_add_multiplier N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
