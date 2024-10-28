`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2024 09:58:16 PM
// Design Name: 
// Module Name: prng_lfsr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module prng_lfsr(
    input  logic clk,                   // Clock signal
    input  logic reset_n,               // Active low reset
    input  logic enable,                // Enable signal for PRNG
    input  logic[15:0] seed,

    output logic [15:0] random_value // Output pseudo-random value
);

    // LFSR register to hold the current state
    logic[15:0] lfsr = 16'hACE1;

    // Initialize LFSR with the seed value
    always_ff @(posedge clk) begin
//    always_ff @(posedge clk or negedge reset_n) begin
//        if (!reset_n)
//            lfsr <= seed;
//        else if (enable)
            // Shift the LFSR and apply the taps
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    // Output the current state as the random value
    assign random_value = lfsr;

endmodule