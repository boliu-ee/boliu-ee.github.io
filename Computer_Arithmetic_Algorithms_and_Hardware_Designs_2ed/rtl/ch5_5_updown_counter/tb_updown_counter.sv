`timescale 1ns/1ps
module tb;
    localparam N = 8;
    reg         clk = 0;
    reg         rst_n;
    reg         en, up, load;
    reg  [N-1:0] din;
    wire [N-1:0] q;
    wire        carry, borrow;
    integer errors = 0;
    integer i;
    reg [N-1:0] model;   // 黄金模型

    updown_counter #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .up(up),
        .load(load), .din(din), .q(q), .carry(carry), .borrow(borrow)
    );

    always #5 clk = ~clk;

    task check;
        input [N-1:0] expected;
        input [127:0] what;
        begin
            if (q !== expected) begin
                errors = errors + 1;
                $display("ERROR [%0s]: q=%h, expected %h", what, q, expected);
            end
        end
    endtask

    initial begin
        rst_n = 0; en = 0; up = 1; load = 0; din = 0;
        #12 rst_n = 1;
        @(posedge clk); #1;

        // 向上计数 200 拍
        model = 0;
        en = 1; up = 1;
        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk); #1;
            model = model + 1'b1;
            check(model, "count up");
        end

        // 回绕检查：继续加到溢出
        for (i = 0; i < 60; i = i + 1) begin
            @(posedge clk); #1;
            model = model + 1'b1;   // 8 位自然回绕
            check(model, "wrap up");
        end

        // 向下计数 100 拍
        up = 0;
        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk); #1;
            model = model - 1'b1;
            check(model, "count down");
        end

        // 加载
        @(negedge clk); din = 8'hA5; load = 1; en = 0;
        @(posedge clk); #1; load = 0; en = 1;
        check(8'hA5, "load");
        model = 8'hA5;

        // 使能关闭时保持
        en = 0;
        repeat (5) begin
            @(posedge clk); #1;
            check(model, "hold");
        end

        if (errors == 0) begin
            $display("TEST PASSED: updown_counter N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
