`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:17:18 PM
// Design Name: 
// Module Name: enemy_texture_rom_1_1
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


module enemy_texture_rom_1_1(
    input [15:0] address,
    output [7:0] data
    );

    logic [7:0] rom [31:0] = {
//        8'hff, 8'hff, 8'h80, 8'h01, 8'h80, 8'h01, 8'h8e, 8'h71, 8'h98, 8'h19, 8'hbf, 8'hfd, 8'hb7, 8'hed, 8'hb6, 8'h6d, 8'hbf, 8'hfd, 8'h8e, 8'h71, 8'h90, 8'h09, 8'h9e, 8'h79, 8'h80, 8'h01, 8'h80, 8'h01, 8'h80, 8'h01, 8'hff, 8'hff
        8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h0e, 8'h70, 8'h18, 8'h18, 8'h3f, 8'hfc, 8'h37, 8'hec, 8'h36, 8'h6c, 8'h3f, 8'hfc, 8'h0e, 8'h70, 8'h10, 8'h08, 8'h1e, 8'h78, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
    };
    
    assign data = rom[address];

endmodule