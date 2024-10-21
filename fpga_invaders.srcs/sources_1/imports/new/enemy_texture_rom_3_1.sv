`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:17:18 PM
// Design Name: 
// Module Name: enemy_texture_rom_3_1
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


module enemy_texture_rom_3_1(
    input [15:0] address,
    output [7:0] data
    );

    logic [7:0] rom [31:0] = {
       8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h1e, 8'h78, 8'h30, 8'h0c, 8'h3f, 8'hfc, 8'h33, 8'hcc, 8'h37, 8'hec, 8'h3f, 8'hfc, 8'h13, 8'hc8, 8'h10, 8'h08, 8'h0e, 8'h70, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
    };
    
    assign data = rom[address];

endmodule