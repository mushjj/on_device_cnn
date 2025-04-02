`timescale 1ns / 1ps


module dsp_int8_packing(
    input wire clk,
    input wire         [ 7:0] a, b,   // 8-bit INT8 inputs
    input wire signed  [ 7:0] c,      // 8-bit INT8 weight
    output reg signed  [47:0] p,      // DSP output
    output wire signed [15:0] a_times_c,
    output wire signed [15:0] b_times_c
);

    // Sign-extend and pack inputs for DSP48E1
    //    wire signed [24:0] packed_ab = {a, 17'b0} + {{17{b[7]}}, b};  // a << 17 + b
    wire signed [17:0] weight_c = {{10{c[7]}},c};           // sign-extended c to 18 bits
    
    wire               [24:0] dspin_a = {1'b0, a, 16'b0};
    wire               [24:0] dspin_b = {{17{b[7]}}, b};

    // DSP result
    wire signed [47:0] dsp_p;

    xbip_dsp48_macro_0 u_dsp (
        .CLK(clk),
        .A(dspin_a),       // 25-bit input
        .D(dspin_b),       // 25-bit input
        .B(weight_c),      // 18-bit weight
        .P(dsp_p)          // 48-bit output
    );

    // Register result
    always @(posedge clk) begin
        p <= dsp_p;
    end

    // Split output
    assign b_times_c = p[15:0];       // Lower product
    assign a_times_c = p[31:16] + 1'b1;

endmodule
