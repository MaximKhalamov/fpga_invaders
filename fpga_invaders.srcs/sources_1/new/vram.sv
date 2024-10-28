`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2024 01:21:39 AM
// Design Name: 
// Module Name: vram
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


module video_ram(
    input logic clk,
    input logic[15:0] address_in,
    input logic[7:0] data_in,
    
    input logic we,
    input logic[15:0] address_out,
    output logic[7:0] data_out,
    input logic[15:0] address_out2,
    output logic[7:0] data_out2
    );
    
    logic [7:0] ram [2047:0];    // vram to change

    always @(posedge clk) begin
        if(we) ram[address_in] <= data_in;
        data_out  <= ram[address_out];
        data_out2 <= ram[address_out2];
    end

endmodule
