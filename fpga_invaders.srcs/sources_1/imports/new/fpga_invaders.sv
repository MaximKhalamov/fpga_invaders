`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2024 01:54:36 PM
// Design Name: 
// Module Name: fpga_invaders
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


module fpga_invaders(
    input  logic clk,
    input  logic btnU,
    input  logic btnL,
    input  logic btnR,
    input  logic btnC,
    
    inout  wire  scl,
    inout  wire  sda,
    
    output logic[9:0] led
	);
	
    logic input_u;
    logic input_l;
    logic input_r;
    logic input_c;
    
    logic [7:0] command_pointer = 0;
    logic [7:0] command_init;
    logic [7:0] command_vram;
    logic [7:0] command;
    
    logic [15:0] address_vram = 0;
    
    logic ready;
    logic enable = 0;
    logic start = 1;
 
    logic [7:0] mode = 8'h00;
 
    logic is_turned_off = 1;
 
    logic [6:0] address = 7'h3C; // Address of OLED screen

    logic sig;
        
    init_command_rom ic_rom(
        .address(command_pointer),
        .data(command_init)
    );
    
    assign sig = is_turned_off & input_c;
    
    i2c_controller_debug i2c_master(
        .clk(clk),
        .rst(sig),  // input_u
        .addr(address),
        .data_in(mode),
        .data_in_2(command),
        .enable(enable),
        .rw(0),         // Write mode
        
        .data_out(),
        .ready(ready),
        
        .i2c_sda(sda),
        .i2c_scl(scl)
    );
    
    game_controller gc(
        .clk(clk),
        .rst(input_c),
        .mov_r(input_r),
        .mov_l(input_l),
        .shot(input_u),
        
        .address_vram(address_vram),
        .data_vram(command_vram),
        .allocated_bullets(led)
    );
    
   always_comb begin 
        if(command_pointer != 30) begin
            command = command_init;
        end else begin
            command = command_vram;
        end
    end
    
    always @(posedge clk) begin
        input_u <= btnU;
        input_l <= btnL;
        input_r <= btnR;
        input_c <= btnC;

//        if(~is_turned_off) begin 
            if (input_c) begin
                is_turned_off <= 1;
                enable <= 0;
                command_pointer <= 0;
                address_vram <= 0;
            end else if (ready) begin
                if(start) start <= 0;
                else if(~enable) begin 
                    if(command_pointer != 30) begin
                        if(command_pointer == 29) mode <= 8'h40;
                        command_pointer <= command_pointer + 1;
                    end else begin
                        if(address_vram == 1023)
                            address_vram <= 0;
                        else
                            address_vram <= address_vram + 1;
                    end
                end
                enable <= 1;  // Start the I2C transaction    
            end
            else begin
                enable <= 0;  // Disable I2C controller after transaction starts
            end    
//        end else if (input_c) is_turned_off <= 0;
    end
    

    
endmodule
