`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2024 11:47:24 PM
// Design Name: 
// Module Name: drawer
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


module drawer(
    input logic clk,
    input logic[3:0] state,     
    input logic[7:0] player_coord,
    
    
    output logic [7:0] vram [1023:0] // vram to change
    
    );

    parameter height = 128;
    parameter width  = 64;
    
    // Number of horizontal bytes per line
    parameter byte_len = 8;

    typedef enum logic[3:0] {
        INIT,
        WAITING,
        PLAYING,
        LOSE,
        WIN
    } player_state;

    // init screen ////////////////////////////////////////
    logic [15:0] isr_ptr = 0;
    logic [7:0] isr_data;
    
    init_screen_rom isr(
        .address(isr_ptr),
        .data(isr_data)
    );
    
    // win screen ////////////////////////////////////////
    logic [15:0] wsr_ptr = 0;
    logic [7:0] wsr_data;
    
    win_screen_rom wsr(
        .address(wsr_ptr),
        .data(wsr_data)
    );
    //////////////////////////////////////////

    // lose screen ////////////////////////////////////////
    logic [15:0] lsr_ptr = 0;
    logic [7:0] lsr_data;
    
    lose_screen_rom lsr(
        .address(lsr_ptr),
        .data(lsr_data)
    );
    //////////////////////////////////////////

    // player texture ////////////////////////////////////////
    parameter p_size = 8;
    parameter p_shift_down = p_size;
    logic [15:0] p_ptr = 0;
    logic [7:0] p_data;
    
    player_texture_rom pr(
        .address(p_ptr),
        .data(p_data)
    );
    
    logic [7:0] player_addr = (p_shift_down + p_ptr) * byte_len + player_coord[7:3];                    

    //////////////////////////////////////////

    typedef enum logic[3:0] {
        DRAW_CLEAR,
        DRAW_PLAYER
    } draw_stage;

    draw_stage ss = DRAW_CLEAR;
    logic[15:0] c_ptr = 0; // clear ptr

    always_ff @(posedge clk) begin 
        case(state)
            WAITING: begin                    
                if(isr_ptr < width * height / 8) begin
                    vram[isr_ptr] <= isr_data;
                    isr_ptr <= isr_ptr + 1;
                end else begin 
                    isr_ptr <= 0;
                end
            end
            
            PLAYING: begin
                case(ss)
                    DRAW_CLEAR:
                        if(c_ptr < height * width / 8) begin
                            vram[c_ptr] <= 8'h00;
                            c_ptr <= c_ptr + 1;
                        end else begin 
                            ss <= DRAW_PLAYER;
                            c_ptr <= 0;
                        end
                    DRAW_PLAYER:
                        if(player_coord == 0) begin
                            if(p_ptr < p_size) begin
                                vram[player_addr] <= p_data;
                                p_ptr <= p_ptr + 1;
                            end else begin 
                                p_ptr <= 0;
                                ss <= DRAW_CLEAR;
                            end
                        end else begin
                            if(p_ptr < p_size) begin
                                vram[player_addr] <= p_data >> player_coord[2:0];
                                vram[player_addr - 1] <= p_data << (3'h7 - player_coord[2:0]);
                                p_ptr <= p_ptr + 1;
                            end else begin 
                                p_ptr <= 0;
                                ss <= DRAW_CLEAR;
                            end                
                        end    
                endcase
                            

//                player_coord
                                
                
            end
            
            LOSE: begin                    
                if(lsr_ptr < width * height / 8) begin
                    vram[lsr_ptr] <= lsr_data;
                    lsr_ptr <= lsr_ptr + 1;
                end else begin 
                    lsr_ptr <= 0;
                end
            end
            WIN: begin                    
                if(wsr_ptr < width * height / 8) begin
                    vram[wsr_ptr] <= wsr_data;
                    wsr_ptr <= wsr_ptr + 1;
                end else begin 
                    wsr_ptr <= 0;
                end
            end
        endcase
    end

endmodule
