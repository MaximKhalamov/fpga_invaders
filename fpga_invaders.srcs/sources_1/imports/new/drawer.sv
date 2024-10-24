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
    input logic[31:0] bullets [7:0],

    output logic active_vram,           // if 0 vram1 is active, if 1 vram2 is active
    
    input logic [15:0] address_vram_display,
    output logic [7:0] data_vram
    
    );

    logic [15:0] address_in;
    logic[7:0] data_in;



    logic[7:0] vram_clk = 0;

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
    
    logic [15:0] player_addr = (p_shift_down + p_ptr) * byte_len - player_coord[7:3];                    
    logic p_column = 0;

    //////////////////////////////////////////

    typedef enum logic[3:0] {
        DRAW_CLEAR,
        DRAW_BULLETS,
        DRAW_PLAYER
    } draw_stage;

    logic selected_vram = 1;

    assign active_vram = ~selected_vram;

    draw_stage ss = DRAW_CLEAR;
    logic[15:0] c_ptr = 0; // clear ptr

    logic[15:0] address_shift = selected_vram * width * height / 8;

    always_ff @(posedge clk)
        vram_clk <= vram_clk + 1;

    logic [7:0] b_ptr = 0;

    logic we = 0;

    video_ram vram(
        .clk(clk),
        .address_in(address_in),
        .data_in(data_in),
        .we(we),
        .address_out(address_vram_display),
        .data_out(data_vram)
    );

    always_ff @(posedge vram_clk[7]) begin 
        case(state)
            WAITING: begin                    
                if(isr_ptr < width * height / 8) begin
                    we <= 1;
                    address_in <= isr_ptr + address_shift;
                    data_in <= isr_data;
                    
                    isr_ptr <= isr_ptr + 1;
                end else begin
                    we <= 0; 
                    isr_ptr <= 0;
                    selected_vram <= ~selected_vram;
                end
            end
            
            PLAYING: begin
                case(ss)
                    DRAW_CLEAR:
                        if(c_ptr < height * width / 8) begin
                            we <= 1;
                            address_in <= c_ptr + address_shift;
                            data_in <= 8'h00;
                            c_ptr <= c_ptr + 1;
                        end else begin 
                            we <= 0;
                            ss <= DRAW_BULLETS;
                            c_ptr <= 0;
                        end
                    DRAW_BULLETS: begin
 
                        // 0: 00000000  xCoord
                        // 1: 00000000  yCoord
                        // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
                        // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)
                        
                        if(b_ptr < 10) begin
//                                vram[ ( bullets[i][31:24] >> 3) + bullets[i][23:16] * byte_len + address_shift] <= ( 1 >> bullets[i][31:24] );
                            we <= 1;
                            address_in <= bullets[b_ptr][31:27] + bullets[b_ptr][23:16] * byte_len + address_shift;
                            data_in <= 1 >> bullets[b_ptr][26:24];
                            b_ptr <= b_ptr + 1;
                        end else begin
                            we <= 0; 
                            ss <= DRAW_PLAYER;
                            b_ptr <= 0;
                        end

                    end
                    DRAW_PLAYER:
                        if(p_ptr < p_size) begin
                            if(p_column == 0) begin 
                                we <= 1;
                                address_in <= player_addr - 1 + address_shift;
                                data_in <= p_data >> player_coord[2:0];
                                p_column <= 1;
                            end else begin
                                we <= 1;
                                address_in <= player_addr - 2 + address_shift;
                                data_in <= p_data << (4'h8 - player_coord[2:0]);
                                p_ptr <= p_ptr + 1;
                                p_column <= 0;
                            end
                        end else begin 
                            we <= 0;
                            p_ptr <= 0;
                            ss <= DRAW_CLEAR;
                            selected_vram <= ~selected_vram;
                        end                
                endcase
            end
            
            LOSE: begin                    
                if(lsr_ptr < width * height / 8) begin
                    we <= 1;
                    address_in <= lsr_ptr + address_shift;
                    data_in <= lsr_data;
                    
                    lsr_ptr <= lsr_ptr + 1;
                end else begin
                    we <= 0; 
                    lsr_ptr <= 0;
                    selected_vram <= ~selected_vram;
                end
            end
            WIN: begin                    
                if(wsr_ptr < width * height / 8) begin
                    we <= 1;
                    address_in <= wsr_ptr + address_shift;
                    data_in <= wsr_data;
                    
                    wsr_ptr <= wsr_ptr + 1;
                end else begin
                    we <= 0; 
                    wsr_ptr <= 0;
                    selected_vram <= ~selected_vram;
                end
            end
        endcase
    end

endmodule
