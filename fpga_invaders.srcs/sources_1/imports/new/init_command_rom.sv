`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2024 02:04:56 PM
// Design Name: 
// Module Name: init_command_rom
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

module init_command_rom(
    input [7:0] address,
    output [7:0] data
    );
      
    parameter[0:30][7:0] rom_init = {
        8'hAE,  // Display OFF
        8'hD5,  // Set clock divide ratio
        8'h80,  // Suggested ratio
        8'hA8,  // Set multiplex ratio
        8'h3F,  // 1/64 duty
        8'hD3,  // Set display offset
        8'h40,  // Set start line address at 0
        8'h8D,  // Charge pump setting
        8'h14,  // Enable charge pump
        8'h20,  // Memory addressing mode
        8'hA1,  // Set segment re-map
        8'hC8,  // Set COM output scan direction
        8'hDA,  // Set COM pins hardware config
        8'h12,  // Alternative COM pin config
        8'h81,  // Set contrast
        8'h7F,  // Contrast level
        8'hD9,  // Set pre-charge period
        8'hF1,  // Phase 1 period
        8'hDB,  // Set VCOMH deselect level
        8'h40,  // 0.77 x Vcc
        8'hA4,  // Entire display ON, resume to RAM content
        8'hA6,  // Normal display
        8'hAF,  // Display ON
        
        // Set the starting column and page address
        8'h21,  // Set column address
        8'h00,  // Start at column 0
        8'h7F,  // End at column 127 (128 columns)
        8'h22,  // Set page address
        8'h00,  // Start at page 0
        8'h07,  // End at page 7 (64 rows / 8 pages)
      
      
        8'hFF
    };
    
    assign data = rom_init[address];
    
endmodule