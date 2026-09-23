`timescale 1ns/1ps
module tb;
    reg         clk = 0, rst_n = 0, start = 0;
    reg  [15:0] z;
    reg  [7:0]  d;
    wire [7:0]  q, r;
    wire        done;
    integer errors = 0;
    integer i;
    reg [15:0] tz_r;
    reg [7:0]  td_r;

    nonrestoring_divider dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .z(z), .d(d), .q(q), .r(r), .done(done)
    );

    always #5 clk = ~clk;

    task check;
        input [15:0] tz;
        input [7:0]  td;
        begin
            @(negedge clk);
            z = tz; d = td; start = 1;
            @(negedge clk);
            start = 0;
            wait (done);
            @(negedge clk);
            if (q !== tz / td || r !== tz % td) begin
                errors = errors + 1;
                $display("ERROR: %0d / %0d -> q=%0d r=%0d, expected q=%0d r=%0d",
                         tz, td, q, r, tz / td, tz % td);
            end
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst_n = 1;
        check(16'd240, 8'd12);      // 20 r0
        check(16'd117, 8'd10);      // 11 r7
        check(16'd0, 8'd5);
        check(16'd1, 8'd1);
        check(16'd65025, 8'd255);   // 255 r0（商边界）
        check(16'd767, 8'd3);       // 255 r2
        check(16'd100, 8'd101);     // q=0 r=100
        check(16'h8000, 8'h81);     // 32768/129 = 253 r131
        for (i = 0; i < 2000; i = i + 1) begin
            td_r = ($random & 8'hFF) | 8'h01;      // 除数非零
            tz_r = $random % (td_r * 256);          // 保证商 < 256（前置条件）
            check(tz_r, td_r);
        end
        if (errors == 0) begin
            $display("TEST PASSED: nonrestoring_divider 16/8");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
