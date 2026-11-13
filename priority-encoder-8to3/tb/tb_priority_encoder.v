`timescale 1ns/1ps
module tb_priority_encoder;
    reg  [7:0] in;
    wire [2:0] out;
    wire       valid;
    integer i, errors;
    reg  [2:0] exp_out;
    reg        exp_valid;

    priority_encoder_8to3 dut (.in(in), .out(out), .valid(valid));

    // Reference model: scan from LSB to MSB, last hit wins
    task compute_expected(input [7:0] v);
        integer k;
        begin
            exp_out = 3'd0; exp_valid = 1'b0;
            for (k = 0; k < 8; k = k + 1)
                if (v[k]) begin exp_out = k[2:0]; exp_valid = 1'b1; end
        end
    endtask

    task check;
        begin
            compute_expected(in);
            #1;
            if (out !== exp_out || valid !== exp_valid) begin
                errors = errors + 1;
                $display("FAIL: in=%b out=%b valid=%b (expected %b %b)",
                          in, out, valid, exp_out, exp_valid);
            end
        end
    endtask

    initial begin
        $dumpfile("priority_encoder.vcd");
        $dumpvars(0, tb_priority_encoder);
        $monitor("Time=%0t | in=%b | out=%b | valid=%b", $time, in, out, valid);
        errors = 0;
        // Directed tests
        in = 8'b00000000; #10 check;
        in = 8'b00000001; #10 check;
        in = 8'b00000010; #10 check;
        in = 8'b00000100; #10 check;
        in = 8'b00001000; #10 check;
        in = 8'b00010000; #10 check;
        in = 8'b00100000; #10 check;
        in = 8'b01000000; #10 check;
        in = 8'b10000000; #10 check;
        // Multiple active inputs
        in = 8'b00001101; #10 check;
        in = 8'b00110110; #10 check;
        in = 8'b01010101; #10 check;
        in = 8'b10101010; #10 check;
        in = 8'b11111111; #10 check;
        // Exhaustive test of all 256 combinations
        for (i = 0; i < 256; i = i + 1) begin
            in = i[7:0]; #5 check;
        end
        if (errors == 0) $display("TEST PASSED: all vectors matched.");
        else             $display("TEST FAILED: %0d mismatches.", errors);
        $finish;
    end
endmodule
