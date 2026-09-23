`timescale 1ns/1ps
// 同一 testbench 同时验证 Kogge-Stone 与 Brent-Kung 两个前缀加法器
module tb;
    localparam N = 16;
    reg  [N-1:0] a, b;
    reg          cin;
    wire [N-1:0] s_ks, s_bk;
    wire         c_ks, c_bk;
    integer errors = 0;
    integer i;

    kogge_stone_adder #(.N(N)) dut_ks (.a(a), .b(b), .cin(cin), .s(s_ks), .cout(c_ks));
    brent_kung_adder #(.N(N)) dut_bk (.a(a), .b(b), .cin(cin), .s(s_bk), .cout(c_bk));

    task check;
        input [N-1:0] ta;
        input [N-1:0] tb_;
        input         tcin;
        reg [N:0] expected;
        begin
            a = ta; b = tb_; cin = tcin;
            #1;
            expected = {1'b0, ta} + {1'b0, tb_} + tcin;
            if ({c_ks, s_ks} !== expected) begin
                errors = errors + 1;
                $display("ERROR [kogge_stone]: a=%h b=%h cin=%b -> got %h, expected %h",
                         ta, tb_, tcin, {c_ks, s_ks}, expected);
            end
            if ({c_bk, s_bk} !== expected) begin
                errors = errors + 1;
                $display("ERROR [brent_kung]: a=%h b=%h cin=%b -> got %h, expected %h",
                         ta, tb_, tcin, {c_bk, s_bk}, expected);
            end
        end
    endtask

    initial begin
        check({N{1'b0}}, {N{1'b0}}, 1'b0);
        check({N{1'b0}}, {N{1'b0}}, 1'b1);
        check({N{1'b1}}, {N{1'b1}}, 1'b1);
        check({N{1'b1}}, {N{1'b0}}, 1'b1);
        check(16'hAAAA, 16'h5555, 1'b1);
        check(16'h00FF, 16'h0001, 1'b0);
        check(16'h0F0F, 16'hF0F0, 1'b1);
        for (i = 0; i < 3000; i = i + 1) begin
            check($random, $random, $random & 1);
        end
        if (errors == 0) begin
            $display("TEST PASSED: kogge_stone_adder & brent_kung_adder N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
