`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2024 03:06:05 PM
// Design Name: 
// Module Name: collision_checker
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


module collision_checker(
    input logic clk,
    input logic rst,
    input logic [7:0] x,
    input logic [7:0] y,
    input logic [7:0] lx,
    input logic [7:0] ly,
    
    input logic [31:0] bullets [9:0],
    
    input logic turn_off,
    
    output logic [7:0] collided_bullet,
    output logic is_not_detected
    );
    
    logic [7:0] out_collided_bullet = 8'hff;
    
    logic detection = 0;
    
    assign collided_bullet = out_collided_bullet;
    assign is_not_detected = ~detection;
    
    logic [7:0] b_ptr = 0;
    
    // 0: 00000000  xCoord
    // 1: 00000000  yCoord
    // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
    // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)
    
    always_ff @(posedge clk) begin
        // if is allocated
        if(rst) begin
            detection <= 0;
            out_collided_bullet <= 8'hff;
        end
        
        if(~detection & bullets[b_ptr][0] == 1) begin 
            if( (bullets[b_ptr][31:24] > x & bullets[b_ptr][31:24] < x + lx)
               &(bullets[b_ptr][23:16] > y & bullets[b_ptr][23:16] < y + ly)) begin
                out_collided_bullet <= b_ptr;
                detection <= 1;
            end
        end
        if(b_ptr < 10) b_ptr <= b_ptr + 1;
        else b_ptr <= 0;
    end
    
endmodule
