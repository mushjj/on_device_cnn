`timescale 1ns / 1ps

module dsp_int8_packing_tb();

    // DUT input signals
    reg clk;
    reg         [ 7:0] a, b;
    reg         [ 7:0] c;

    // DUT output signals
    wire signed [47:0] p;
    wire signed [15:0] a_times_c;
    wire signed [15:0] b_times_c;

    // Instantiate DUT
    dsp_int8_packing dut (
        .clk(clk),
        .a(a),
        .b(b),
        .c(c),
        .p(p),
        .a_times_c(a_times_c),
        .b_times_c(b_times_c)
    );

    // Clock generator: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize inputs
        a = 0; b = 0; c = 0;

        // Wait a bit for global reset
        #20;

        // Test vector set
        test_case(8'd10, 8'd5, -8'd3);     // a*c = 30, b*c = 15, P = (30<<8) + 15 = 7680 + 15 = 7695
        test_case(8'd12, 8'd4, -8'd2);    // a*c = -24, b*c = 8,  P = (-24<<8) + 8 = -6144 + 8 = -6136
        test_case(8'd1 , 8'd1, -8'd1);    // a*c = -1, b*c = 1,  P = (-1<<8) + 1 = -256 + 1 = -255
        test_case(8'd50, 8'd20, -8'd1);  // a*c = -50, b*c = -20, P = (-50<<8) + (-20) = -12800 - 20 = -12820
        test_case(8'd17, 8'd98, -8'd63);

        $display("All test cases complete.");
        #20;
        $stop;
    end

    task test_case(input [7:0] ta, tb, input signed [7:0] tc);
        reg signed [15:0] expected_ac;
        reg signed [15:0] expected_bc;
        reg signed [47:0] expected_p;
        begin
            @(posedge clk);
            a <= ta;
            b <= tb;
            c <= tc;
            
            #(4*10)
            
            expected_ac = ta * tc;
            expected_bc = tb * tc;
            expected_p  = (expected_ac <<< 8) + expected_bc;

            $display("a=%d, b=%d, c=%d => a*c=%d, b*c=%d", ta, tb, tc, expected_ac, expected_bc);
            $display(" DUT Output:   a*c = %d, b*c = %d, P = %d", a_times_c, b_times_c, p);
            $display(" Expected P:   %d", expected_p);

            if (p !== expected_p)
                $display("ERROR: Mismatch!\n");
            else
                $display("PASS\n");
        end
    endtask

endmodule
