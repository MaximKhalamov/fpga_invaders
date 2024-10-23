`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2024 06:44:12 PM
// Design Name: 
// Module Name: game_controller
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


module game_controller(
    input logic clk,
    input logic rst,
    input logic mov_r,
    input logic mov_l,
    input logic shot,

    input logic [15:0] address_vram,    
    
    output logic is_win,
    output logic is_lost,
    
    output logic [7:0] data_vram
    );
    
    parameter enemy_n_w = 4;
    parameter enemy_n_h = 5;
    
    parameter enemy_number = enemy_n_w * enemy_n_h;
    parameter max_bullet_number = 8;
    
    parameter enemy_size = 9;

    typedef enum logic[3:0] {
        INIT,
        WAITING,
        PLAYING,
        LOSE,
        WIN
    } player_state;

    player_state state = INIT;

    parameter height  = 128;
    parameter width = 64;

    // Memory to display
    logic [7:0] vram [ 2 * width * height / 8 - 1 : 0 ];     // 2x   64 x 128 screen   
    
    // 0: 11111111   xCoord -- left 
    // 1: 11111111   yCoord -- up
    logic [ 15:0 ] coord;

    // 0: left
    // 1: down and change direction to right
    // 2: right
    // 3: down and change direction to right
    logic [ 1:0 ] direction;

    
    // 0: 1111
    // 1: 1111   enemy map; 1 if alive 0 if dead
    // 2: 1111
    logic [ enemy_number - 1 : 0 ]enemy_map;
    
    // 0: 00000000  xCoord
    // 1: 00000000  number of lives
    logic [ 15:0 ] player;
    
    // 0: 00000000  xCoord
    // 1: 00000000  yCoord
    // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
    // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)
    logic [ 31:0 ] bullets [ max_bullet_number - 1 : 0 ];

    logic active_vram;

    logic[21:0] counter_clk = 0;

    always_ff @(posedge clk) begin 
        counter_clk <= counter_clk + 1;        
    end

    drawer drw(
        .clk(clk),
        .state(state),
        .player_coord(player[15:8]),
        .active_vram(active_vram),
        .vram(vram)
    );

    always_comb begin 
        if(address_vram < width * height / 8)
            //  Full address of vram using 2 vram spaces for bufferization
            data_vram = vram[address_vram + active_vram * width * height / 8];
        else
            data_vram = 8'h0F;
    end

    logic rst_hold = 0;

    integer i;
    
    // ~21 Hz
    always_ff @(posedge counter_clk[21]) begin
        if(rst) begin 
            state <= INIT;
        end else
            case(state)
                INIT: begin
                    enemy_map    <= 9'b111_111_111;  // regenerating map
                    player[15:8] <= 8'd32;     // Set x coordinate 32
                    player[7:0]  <= 8'd3;      // Set 3 lives
                    
                    for (i = 0; i < max_bullet_number; i = i + 1) begin
                        bullets[i] <= 32'h00000000;
                    end 
                    
//                    for (i = 0; i < width * height / 8; i = i + 1) begin
//                        vram[i] <= 8'hff;
//                    end
                    
                    state <= WAITING;
                end
                WAITING: begin                    
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= PLAYING;
                    end
                end
                
                PLAYING: begin                    
                    if(mov_r) begin 
                        if(player[15:8] != 8'd56)
                            player[15:8] <= player[15:8] + 1;                        
                    end

                    // 0: 00000000  xCoord
                    // 1: 00000000  yCoord
                    // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
                    // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)

                    if(shot) begin 
                        for (i = 0; i < max_bullet_number; i = i + 1) begin
                            if(bullets[i])
                            bullets[i] <= 32'h00_00_00_01;
                        end 
                    end
                    
                    if(mov_l) begin 
                        if(player[15:8] != 0)
                            player[15:8] <= player[15:8] - 1;
                    end
                end
                
                LOSE: begin                                        
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= INIT;
                    end
                end
                WIN: begin                    
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= INIT;
                    end
                end
            endcase
        end
endmodule
