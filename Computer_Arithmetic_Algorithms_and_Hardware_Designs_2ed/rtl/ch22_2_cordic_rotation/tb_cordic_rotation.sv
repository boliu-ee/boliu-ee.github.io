`timescale 1ns/1ps
// 定向校验：预期值为 cos/sin 真值 * 2^14（四舍五入），容差 ±150（约 0.009 rad 精度）
module tb;
    reg               clk = 0, rst_n = 0, start = 0;
    reg  signed [15:0] angle;
    wire signed [15:0] cos_o, sin_o;
    wire              done;
    integer errors = 0;

    cordic_rotation dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .angle(angle), .cos_o(cos_o), .sin_o(sin_o), .done(done)
    );

    always #5 clk = ~clk;

    function integer abs_i;
        input integer v;
        abs_i = (v < 0) ? -v : v;
    endfunction

    task check;
        input signed [15:0] ang;
        input integer ec, es;   // 期望 cos/sin（Q2.14）
        begin
            @(negedge clk);
            angle = ang; start = 1;
            @(negedge clk);
            start = 0;
            wait (done);
            @(negedge clk);
            if (abs_i(cos_o - ec) > 150 || abs_i(sin_o - es) > 150) begin
                errors = errors + 1;
                $display("ERROR: angle=%0d -> cos=%0d (exp %0d) sin=%0d (exp %0d)",
                         ang, cos_o, ec, sin_o, es);
            end else begin
                $display("ok: angle=%0d -> cos=%0d sin=%0d", ang, cos_o, sin_o);
            end
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst_n = 1;
        check(16'sd0,      16384, 0);        // 0 rad
        check(16'sd12867,  11585, 11585);    // pi/4
        check(16'sd8192,   14376, 7855);     // 0.5 rad
        check(-16'sd8192,  14376, -7855);    // -0.5 rad
        check(16'sd16384,  8852,  13787);    // 1.0 rad
        check(16'sd4096,   15893, 4067);     // 0.25 rad
        check(-16'sd12867, 11585, -11585);   // -pi/4
        if (errors == 0) begin
            $display("TEST PASSED: cordic_rotation Q2.14 12-iter");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
