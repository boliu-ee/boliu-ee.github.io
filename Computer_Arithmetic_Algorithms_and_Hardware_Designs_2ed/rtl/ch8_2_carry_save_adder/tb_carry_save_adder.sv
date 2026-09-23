`timescale 1ns/1ps
module tb;
    localparam N = 16;
    reg  [N-1:0] x, y, z;
    wire [N-1:0] s, c;
    wire         cout;
    wire [N+1:0] sum4;
    reg  [N-1:0] x0, x1, x2, x3;
    integer errors = 0;
    integer i;

    carry_save_adder #(.N(N)) dut (.x(x), .y(y), .z(z), .s(s), .c(c), .cout(cout));
    csa_tree4 #(.N(N)) dut4 (.x0(x0), .x1(x1), .x2(x2), .x3(x3), .sum(sum4));

    task check_csa;
        input [N-1:0] tx, ty, tz;
        reg [N+1:0] expected;
        reg [N+1:0] got;
        begin
            x = tx; y = ty; z = tz;
            #1;
            expected = {2'b0, tx} + {2'b0, ty} + {2'b0, tz};
            got = {2'b0, s} + {2'b0, c} + (cout << N);
            if (got !== expected) begin
                errors = errors + 1;
                $display("ERROR [csa]: x=%h y=%h z=%h -> s+c+(cout<<N)=%h, expected %h",
                         tx, ty, tz, got, expected);
            end
        end
    endtask

    task check_tree4;
        input [N-1:0] t0, t1, t2, t3;
        reg [N+1:0] expected;
        begin
            x0 = t0; x1 = t1; x2 = t2; x3 = t3;
            #1;
            expected = {2'b0, t0} + {2'b0, t1} + {2'b0, t2} + {2'b0, t3};
            if (sum4 !== expected) begin
                errors = errors + 1;
                $display("ERROR [tree4]: %h+%h+%h+%h -> %h, expected %h",
                         t0, t1, t2, t3, sum4, expected);
            end
        end
    endtask

    initial begin
        check_csa({N{1'b0}}, {N{1'b0}}, {N{1'b0}});
        check_csa({N{1'b1}}, {N{1'b1}}, {N{1'b1}});
        check_csa({N{1'b1}}, {N{1'b0}}, {N{1'b0}});
        check_csa(16'hAAAA, 16'h5555, 16'hFFFF);
        check_tree4({N{1'b0}}, {N{1'b0}}, {N{1'b0}}, {N{1'b0}});
        check_tree4({N{1'b1}}, {N{1'b1}}, {N{1'b1}}, {N{1'b1}});
        check_tree4(16'h1234, 16'h5678, 16'h9ABC, 16'hDEF0);
        for (i = 0; i < 2000; i = i + 1) begin
            check_csa($random, $random, $random);
            check_tree4($random, $random, $random, $random);
        end
        if (errors == 0) begin
            $display("TEST PASSED: carry_save_adder & csa_tree4 N=%0d", N);
            $finish;
        end else begin
            $display("TEST FAILED: %0d errors", errors);
            $fatal(1);
        end
    end
endmodule
