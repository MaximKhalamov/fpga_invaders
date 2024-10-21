`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:17:18 PM
// Design Name: 
// Module Name: player_texture_rom
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


module player_texture_rom(
    input [15:0] address,
    output [7:0] data
    );

    logic [7:0] rom [7:0] = {
       8'h00, 8'h18, 8'h3c, 8'h7e, 8'h5a, 8'h18, 8'h3c, 8'h24
    };
    
    assign data = rom[address];

endmodule