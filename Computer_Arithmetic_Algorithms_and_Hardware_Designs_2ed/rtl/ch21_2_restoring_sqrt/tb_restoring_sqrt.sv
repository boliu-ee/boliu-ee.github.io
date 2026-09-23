`timescale 1ns/1ps
module tb;
    reg         clk = 0, rst_n = 0, start = 0;
    reg  [15:0] d;
    wire [7:0]  q, r;
    wire        done;
    integer errors = 0;
    integer i;

    restoring_sqrt dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .d(d), .q(q), .r(r), .done(done)
    );

    always #5 clk = ~clk;

    task check;
        input [15:0] td;
        reg [7:0] eq;
        reg [16:0] er;
        begin
            @(negedge clk);
            d = td; start = 1;
            @(negedge clk);
            start = 0;
            wait (done);
            @(negedge clk);
            // 黄金模型：q = floor(sqrt(td))，r = td - q*q
            eq = 0;
            while ((eq + 1) * (eq + 1) <= td) eq = eq + 1;
            er = td - eq * eq;
            if (q !== eq || r !== er[7:0]) begin
                errors = errors + 1;
                $display("ERROR: sqrt(%0d) -> q=%0d r=%0d, expected q=%0d r=%0d",
                         td, q, r, eq, er);
            end
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst_n = 1;
        check(16'd0);
        check(16'd1);
        check(16'd2);        // q=1 r=1
        check(16'd240);      // q=15 r=15
        check(16'd225);      // q=15 r=0
        check(16'd65025);    // 255^2，q=255 r=0
        check(16'hFFFF);     // q=255 r=510
        check(16'd1024);     // q=32
        for (i = 0; i < 1000; i = i + 1) begin
            check($random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: restoring_sqrt 16->8");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
