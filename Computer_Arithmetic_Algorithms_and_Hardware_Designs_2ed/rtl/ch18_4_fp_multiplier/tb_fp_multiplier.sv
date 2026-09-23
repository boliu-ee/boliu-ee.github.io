`timescale 1ns/1ps
module tb;
    reg  [31:0] a, b;
    wire [31:0] p;
    integer errors = 0;

    fp_multiplier dut (.a(a), .b(b), .p(p));

    task check;
        input [31:0] ta, tb_, expected;
        begin
            a = ta; b = tb_;
            #1;
            if (p !== expected) begin
                errors = errors + 1;
                $display("ERROR: %h * %h -> %h, expected %h", ta, tb_, p, expected);
            end
        end
    endtask

    initial begin
        // 1.0 * 1.0 = 1.0
        check(32'h3F800000, 32'h3F800000, 32'h3F800000);
        // 2.0 * 3.0 = 6.0
        check(32'h40000000, 32'h40400000, 32'h40C00000);
        // 0.5 * 0.25 = 0.125
        check(32'h3F000000, 32'h3E800000, 32'h3E000000);
        // 1.5 * 1.5 = 2.25
        check(32'h3FC00000, 32'h3FC00000, 32'h40100000);
        // -2.5 * 4.0 = -10.0
        check(32'hC0200000, 32'h40800000, 32'hC1200000);
        // 符号组合：2.5 * -4.0 = -10.0
        check(32'h40200000, 32'hC0800000, 32'hC1200000);
        // 0 * x = +0（0 * -x = -0）
        check(32'h00000000, 32'h40400000, 32'h00000000);
        check(32'h00000000, 32'hC0400000, 32'h80000000);
        // 1.0000001 * 1.0 = 1.0000001（尾数直通）
        check(32'h3F800001, 32'h3F800000, 32'h3F800001);
        // 精确可表示：(1+2^-11)^2 = 1+2^-10+2^-22（全部落在 24 位尾数内）
        check(32'h3F801000, 32'h3F801000, 32'h3F802002);
        // RNE 平局取偶：(1+2^-11)*(1+2^-13) = 1+2^-11+2^-13+2^-24，
        // 2^-24 恰为半个 ulp，低位候选 LSB 为偶 -> 舍去
        check(32'h3F801000, 32'h3F800400, 32'h3F801400);
        // 上溢饱和：2^100 * 2^100（阶码 227）-> 饱和最大规格数
        check(32'h71800000, 32'h71800000, 32'h7F7FFFFF);
        // 下溢刷零：2^-100 * 2^-100 -> +0
        check(32'h0D800000, 32'h0D800000, 32'h00000000);
        // 负上溢饱和
        check(32'hF1800000, 32'h71800000, 32'hFF7FFFFF);
        if (errors == 0) begin
            $display("TEST PASSED: fp_multiplier binary32 (normals, RNE)");
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
