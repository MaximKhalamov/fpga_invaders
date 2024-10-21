`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:17:18 PM
// Design Name: 
// Module Name: enemy_texture_rom_2_2
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


module enemy_texture_rom_2_2(
    input [15:0] address,
    output [7:0] data
    );

    logic [7:0] rom [31:0] = {
        8'h00, 8'h00, 8'h00, 8'h00, 8'h01, 8'h80, 8'h07, 8'he0, 8'h1f, 8'hf8, 8'h3f, 8'hfc, 8'h37, 8'hec, 8'h33, 8'hcc, 8'h3f, 8'hfc, 8'h12, 8'h48, 8'h12, 8'h48, 8'h24, 8'h90, 8'h24, 8'h90, 8'h24, 8'h90, 8'h00, 8'h00, 8'h00, 8'h00
    };
    
    assign data = rom[address];

endmodule