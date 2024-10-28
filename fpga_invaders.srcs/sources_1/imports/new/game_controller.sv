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
    
    output logic [7:0] data_vram,
    output logic [9:0] allocated_bullets
    );
    
    parameter enemy_n_w = 3;
    parameter enemy_n_h = 4;
    
    parameter enemy_number = enemy_n_w * enemy_n_h;
    parameter max_bullet_number = 10;
    
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
    parameter SHOT_TIMING = 24;


    // 0: left
    // 1: down and change direction to right
    // 2: right
    // 3: down and change direction to left
    logic [ 1:0 ] direction = 2;
    
    // 0: 111
    // 1: 111   enemy map; 1 if alive 0 if dead
    // 2: 111
    // 3: 111
    logic [ enemy_number - 1 : 0 ] enemy_map;
    logic [ enemy_number - 1 : 0 ] detection_map;
    logic [7:0] enemy_x = 8;
    logic [7:0] enemy_y = 102;
    
    // 0: 00000000  xCoord
    // 1: 00000000  number of lives
    logic [ 15:0 ] player;
    
    logic [4:0] bullet_timing;
    
    // 0: 00000000  xCoord
    // 1: 00000000  yCoord
    // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
    // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)
    logic [ 31:0 ] bullets [ max_bullet_number - 1 : 0 ];

    logic active_vram;

    logic[31:0] counter_clk = 0;

    always_ff @(posedge clk) begin 
        counter_clk <= counter_clk + 1;        
    end

    logic [15:0] address_vram_display;

    //  Full address of vram using 2 vram spaces for bufferization
    assign address_vram_display = address_vram + active_vram * width * height / 8;

    drawer drw(
        .clk(clk),
        .state(state),
        .player_coord(player[15:8]),
        .active_vram(active_vram),
        .bullets(bullets),
        .enemy_map(enemy_map),
        .enemy_x(enemy_x),
        .enemy_y(enemy_y),
        .address_vram_display(address_vram_display),
        .data_vram(data_vram)
    );

    assign allocated_bullets[0] = bullets[0][0];
    assign allocated_bullets[1] = bullets[1][0];
    assign allocated_bullets[2] = bullets[2][0];
    assign allocated_bullets[3] = bullets[3][0];
    assign allocated_bullets[4] = bullets[4][0];
    assign allocated_bullets[5] = bullets[5][0];
    assign allocated_bullets[6] = bullets[6][0];
    assign allocated_bullets[7] = bullets[7][0];
    assign allocated_bullets[8] = bullets[8][0];
    assign allocated_bullets[9] = bullets[9][0];

    logic rst_hold = 0;

    integer i;
    integer j;  // enemy shot

    logic rst_collision = 1;
  
    logic [7:0] collided_bullets [enemy_number - 1:0];
    logic [enemy_number-1:0] collided_bullets_map = 0;
  
    genvar gv;   
    generate
        for(gv = 0; gv < enemy_number; gv++) begin
            collision_checker cc(
            .clk(clk),
            .rst(rst_collision),
            .x(enemy_x + gv % enemy_n_w * 8 * 2),
            .y(enemy_y - gv / enemy_n_w * 8 * 2),
            .lx(8'd12),
            .ly(8'd12),
            .bullets(bullets),
            .is_not_detected(detection_map[enemy_number - 1 - gv]),
            .collided_bullet(collided_bullets[gv])
        ); 
        end
    endgenerate
    
    logic player_not_damaged;
    
    collision_checker mc_cc(
        .clk(clk),
        .rst(rst_collision),
        .x(player[15:8]-4),
        .y(8'd8),
        .lx(8'd8),
        .ly(8'd8),
        .bullets(bullets),
        .is_not_detected(player_not_damaged)
    );
    
    logic reset_rng = 0;
    logic[15:0] value_rng;
    
    prng_lfsr rng(
        .clk(clk),
        .seed(counter_clk[15:0]),
        .reset_n(reset_rng),
        .enable(1),
        
        .random_value(value_rng)
    );
        
    // counter_clk[21] is ~21 Hz
    always_ff @(posedge counter_clk[21]) begin
        if(rst) begin 
            state <= INIT;
        end else
            case(state)
                INIT: begin
                    rst_collision <= 1;
                    bullet_timing <= SHOT_TIMING;
                    enemy_map     <= 12'b111_111_111_111;  // regenerating map
                    player[15:8]  <= 8'd32;                         // Set x coordinate 32
                    player[7:0]   <= 8'd3;                          // Set 3 lives
                    direction     <= 2'b10;
                    enemy_x       <= 8;
                    enemy_y       <= 102;
                    for (i = 0; i < max_bullet_number; i = i + 1) begin
                        bullets[i] <= 32'hff_00_00_00;
                    end 
                    collided_bullets_map <= 0;
                    state <= WAITING;
                end
                WAITING: begin
                    reset_rng <= 1;         
                    rst_collision <= 0;           
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= PLAYING;
                    end
                end
                
                PLAYING: begin
                    rst_collision <= 0;
                    enemy_map <= detection_map & enemy_map;
                
                    case(direction)
                        2'b00: begin 
                            enemy_x <= enemy_x - 1;
                            if(enemy_x == 1) direction <= 2'b01;
                        end
                        2'b01: begin 
                            enemy_y <= enemy_y - 1;
                            direction <= 2'b10;        
                        end
                        2'b10: begin 
                            enemy_x <= enemy_x + 1;
                            if(enemy_x == 15) direction <= 2'b11;
                        end  
                        2'b11: begin 
                            enemy_y <= enemy_y - 1;
                            direction <= 2'b00;
                        end
                    endcase

                    if(bullet_timing > 0)
                        bullet_timing <= bullet_timing - 1;

                    if(mov_r) begin 
                        if(player[15:8] != 8'd56)
                            player[15:8] <= player[15:8] + 1;                        
                    end

                    if(mov_l) begin 
                        if(player[15:8] != 0)
                            player[15:8] <= player[15:8] - 1;
                    end

                    // 0: 00000000  xCoord
                    // 1: 00000000  yCoord
                    // 2: 00000000  move direction (if 1 -- up) (if 0 -- down)
                    // 3: 00000000  is allocated   (if 1 -- allocated) (if 0 -- not allocated)

                    if(shot & bullet_timing == 0) begin
                        for (i = 0; i < max_bullet_number; i = i + 1) begin
                            if(bullets[i][0] == 0) begin
                                bullets[i][31:24] <= player[15:8];
                                bullets[i][23:0]  <= 24'h12_01_01;
                                bullet_timing     <= SHOT_TIMING; 
                                break;   
                            end
                        end 
                    end

                    // 0: 111
                    // 1: 111   enemy map; 1 if alive 0 if dead
                    // 2: 111
                    // 3: 111

                    // value_rng[5:4] -- column number
                    if(value_rng[3:0] == 4'b0000 & value_rng[5:4] != 3)
                        for (i = 0; i < max_bullet_number; i = i + 1)
                            if(bullets[i][0] == 0) begin
                                for(j = 0; j < enemy_n_h; j++)
                                    if(enemy_map[value_rng[5:4] + j * enemy_n_w] == 1) begin
                                        bullets[i][31:24] <= 32 - value_rng[5:4] * 16 + enemy_x;
                                        bullets[i][23:16] <= enemy_y - 16 * (enemy_n_h - j - 1);
                                        bullets[i][15:0]  <= 16'h00_01;
                                        break;
                                    end
                                break;
                            end

                    for (i = 0; i < max_bullet_number; i = i + 1) begin
                        if(bullets[i][0] != 0) begin
                            if(bullets[i][8] == 0)
                                bullets[i] <= bullets[i] - (1 << 16);
                            else
                                bullets[i] <= bullets[i] + (1 << 16);                           
                        end
                        
                        if(bullets[i][23:16] > height + 1)
                            bullets[i] <= 32'hff_00_00_00;
                    end

                    for (i = 0; i < enemy_number; i = i + 1) begin
                        if(collided_bullets[i] != 8'hff) begin 
                            if(collided_bullets_map[i] == 0) begin 
                                bullets[collided_bullets[i]] <= 32'hff_00_00_00;
                                collided_bullets_map[i] <= 1;
                            end
                        end
                    end
                    
                    
                    if(|enemy_map[2:0] != 0) begin 
                        if(enemy_y < 8'd64) state <= LOSE;
                    end else if(|enemy_map[5:3] != 0) begin
                        if(enemy_y < 8'd48) state <= LOSE; 
                    end else if(|enemy_map[8:6] != 0) begin
                        if(enemy_y < 8'd32) state <= LOSE;
                    end else if(|enemy_map[11:9] != 0) begin 
                        if(enemy_y < 8'd16) state <= LOSE;
                    end
                    
                    if(|enemy_map == 0)
                        state <= WIN;
                        
                    // if no lives
                    if(~player_not_damaged)
                        state <= LOSE;
                end
                
                LOSE: begin             
                    rst_collision <= 1;                           
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= INIT;
                    end
                end
                WIN: begin              
                    rst_collision <= 1;        
                    if(~shot & ~rst_hold)
                        rst_hold <= 1;
                    
                    if(shot & rst_hold) begin
                        rst_hold <= 0;                     
                        state <= INIT;
                    end
                end
            endcase
        end
        
//            parameter enemy_n_w = 3;
//            parameter enemy_n_h = 4;
        

        
endmodule
