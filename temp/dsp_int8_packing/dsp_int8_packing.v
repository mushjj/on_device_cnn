`timescale 1ns / 1ps


module dsp_int8_packing(
    input wire clk,
    input wire         [ 7:0] a, b,   // 8-bit INT8 inputs
    input wire signed  [ 7:0] c,      // 8-bit INT8 weight
    output reg signed  [32:0] p,      // DSP output
    output wire signed [15:0] ac,
    output wire signed [15:0] bc
);

    // Sign-extend and pack inputs for DSP48E1
    //    wire signed [24:0] packed_ab = {a, 17'b0} + {{17{b[7]}}, b};  // a << 17 + b
    // wire signed [17:0] weight_c = {{10{c[7]}},c};           // sign-extended c to 18-bits
    wire signed [ 7:0] weight_c = c;                           // just 8-bits
    
    wire               [23:0] dspin_a = {a, 16'b0};
    wire               [23:0] dspin_b = {{16{b[7]}}, b};

    // DSP result
    wire signed [32:0] dsp_p;

    xbip_dsp48_macro_0 u_dsp (
        .CLK(clk),
        .A(dspin_a),       // 25-bit input  -> 24-bit input
        .D(dspin_b),       // 25-bit input  -> 24-bit input
        .B(weight_c),      // 18-bit weight ->  7-bit input
        .P(dsp_p)          // 48-bit output -> 33-bit output
    );

    // Register result
    always @(posedge clk) begin
        p <= dsp_p;
    end

    // Split output
    assign bc = p[15:0];            // Lower product
    assign ac = p[31:16] + 1'b1;    // Upper product

endmodule
