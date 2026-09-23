`timescale 1ns/1ps
module tb;
    reg  [7:0]  a, b;
    wire signed [15:0] p;
    integer errors = 0;
    integer i;

    booth_radix4_multiplier dut (.a(a), .b(b), .p(p));

    task check;
        input [7:0] ta;
        input [7:0] tb_;
        reg signed [15:0] sea, seb;
        reg signed [31:0] expected;
        begin
            a = ta; b = tb_;
            #1;
            sea = $signed(ta);      // 符号扩展后相乘作为黄金模型
            seb = $signed(tb_);
            expected = sea * seb;
            if (p !== expected[15:0]) begin
                errors = errors + 1;
                $display("ERROR: %0d * %0d -> %0d, expected %0d",
                         $signed(ta), $signed(tb_), $signed(p), expected);
            end
        end
    endtask

    initial begin
        check(8'd0, 8'd0);
        check(8'd1, 8'd1);
        check(8'd6, 8'hFA);      // 6 * (-6) = -36
        check(8'hF6, 8'hF5);     // (-10) * (-11) = 110
        check(8'h80, 8'h80);     // (-128) * (-128) = 16384
        check(8'h80, 8'h7F);     // (-128) * 127 = -16256
        check(8'h7F, 8'h7F);     // 127 * 127 = 16129
        check(8'hFF, 8'h01);     // -1 * 1
        check(8'h55, 8'hAA);     // 85 * (-86)
        for (i = 0; i < 3000; i = i + 1) begin
            check($random, $random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: booth_radix4_multiplier 8x8 signed");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
