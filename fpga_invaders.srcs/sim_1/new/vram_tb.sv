`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2024 02:45:10 PM
// Design Name: 
// Module Name: vram_tb
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


module i2c_test_tb;
    logic clk = 0;
    wire scl;
    wire sda;

    logic btnU = 0;
    logic btnL = 0;
    logic btnR = 0;
    logic btnC = 0;

    i2c_test uut(
        .clk(clk),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .scl(scl),
        .sda(sda)
    );

    always #5 clk = ~clk;

    initial begin
        btnU = 0;
        btnL = 0;
        btnR = 0;
        btnC = 0;

        #1_000 btnC = 1;
        #1_000 btnC = 0;
        
        #100_000_000 btnU = 1;
    end

endmodule
