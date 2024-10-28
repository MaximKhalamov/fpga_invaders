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
    input logic[3:0]  state,     
    input logic[7:0]  player_coord,
    input logic[31:0] bullets [9:0],
    input logic[19:0] enemy_map,
    input logic[7:0]  enemy_x,
    input logic[7:0]  enemy_y,


    output logic active_vram,           // if 0 vram1 is active, if 1 vram2 is active
    
    input logic [15:0] address_vram_display,
    output logic [7:0] data_vram
    
    );

    logic [15:0] address_in;
    logic[7:0] data_in;



    logic[23:0] vram_clk = 0;

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

//     init screen ////////////////////////////////////////
    logic [15:0] isr_ptr = 0;
    logic [7:0] isr_data;
    
    init_screen_rom isr(
        .address(isr_ptr),
        .data(isr_data)
    );
    //////////////////////////////////////////
    
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

    // enemy texture ////////////////////////////////////////
    parameter en_size = 32;
    
    parameter ENEMY_NUMBER_WIDTH = 3;
    parameter ENEMY_NUMBER_HEIGHT = 4;
    parameter ENEMY_NUMBER = 12;

    // shift in bytes
    parameter ENEMY_SHIFT = 2;

    logic [7:0] en_n_width = 0;
    logic [7:0] en_n_height = 0;

    logic [15:0] addres_enemy_texture = 0;
    logic [7:0] enemy_texture;
    
    logic [7:0] enemy_counter = 0;
    
    logic [15:0] en_ptr  = 0;
    logic [7:0] en_data;
        
    logic en_column = 0;
    
    // Get byte from VRAM which will be added to another byte texture 
    logic got_vram = 0;
    
    // animation bit
    // | 
    // 000
    //  ||
    // number of texture
    logic [2:0] texture_number;

    logic [7:0]  en11_data;
    logic [7:0]  en12_data;
    logic [7:0]  en21_data;
    logic [7:0]  en22_data;
    logic [7:0]  en31_data;
    logic [7:0]  en32_data;

    always_comb begin
        case(texture_number)
            3'b000:  en_data = en11_data;
            3'b001:  en_data = en21_data;
            3'b010:  en_data = en31_data;
            3'b100:  en_data = en12_data;
            3'b101:  en_data = en22_data;
            3'b110:  en_data = en32_data;
            default: en_data = 8'hAA;
        endcase
    end



    enemy_texture_rom_1_1 etr11(
        .address(en_ptr),
        .data(en11_data)
    );

    enemy_texture_rom_1_2 etr12(
        .address(en_ptr),
        .data(en12_data)
    );
    
    enemy_texture_rom_2_1 etr21(
        .address(en_ptr),
        .data(en21_data)
    );
    
    enemy_texture_rom_2_2 etr22(
        .address(en_ptr),
        .data(en22_data)
    );
    
    enemy_texture_rom_3_1 etr31(
        .address(en_ptr),
        .data(en31_data)
    );
    
    enemy_texture_rom_3_2 etr32(
        .address(en_ptr),
        .data(en32_data)
    );
    
    //////////////////////////////////////////    


    typedef enum logic[3:0] {
        DRAW_CLEAR,
        DRAW_BULLETS,
        DRAW_ENEMIES,
        DRAW_PLAYER
    } draw_stage;

    logic selected_vram = 1;

    assign active_vram = ~selected_vram;

    draw_stage ss = DRAW_CLEAR;
    logic [15:0] c_ptr = 0; // clear ptr

    logic [15:0] address_shift = selected_vram * width * height / 8;  

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
        .data_out(data_vram),

        .address_out2(addres_enemy_texture),
        .data_out2(enemy_texture)
    );

    always_ff @(posedge vram_clk[1]) begin 
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
                        // if bullet is allocated
                            if(bullets[b_ptr][0] == 0) begin 
                                b_ptr <= b_ptr + 1;                    
                            end else begin
                                we <= 1;
//                              vram[ ( bullets[i][31:24] >> 3) + bullets[i][23:16] * byte_len + address_shift] <= ( 1 >> bullets[i][31:24] );
                                        //(p_shift_down + p_ptr) * byte_len - player_coord[7:3];
                                if(bullets[b_ptr][26:24] > 4) begin
                                    address_in <= bullets[b_ptr][23:16] * byte_len - 2 - bullets[b_ptr][31:27] + address_shift;                             
                                            // middle of starship
                                    data_in <= 8'b0001_0000 << (4'h8 - bullets[b_ptr][26:24]);
                                end else begin                        
                                    address_in <= bullets[b_ptr][23:16] * byte_len - 1 - bullets[b_ptr][31:27] + address_shift;
                                    data_in <= 8'b0001_0000 >> bullets[b_ptr][26:24];
                                end
                                b_ptr <= b_ptr + 1;
                            
                            end

                        end else begin
                            we <= 0; 
                            ss <= DRAW_ENEMIES;
                            b_ptr <= 0;
                        end

                    end
                    
//                    logic [15:0] en11_ptr = 0;
//                    logic [7:0] en11_data;
                        
//                    enemy_texture_rom_1_1 etr11(
//                        .address(en11_ptr),
//                        .data(en11_data)
//                    );
                        
//                    logic [1:0] en_column = 0;
                    DRAW_ENEMIES: begin
                        if(enemy_counter != ENEMY_NUMBER) begin
                            texture_number <= ((enemy_counter / ENEMY_NUMBER_WIDTH) % 3) | vram_clk[20] << 2;
//                            texture_number <= {vram_clk[13], (enemy_counter / ENEMY_NUMBER_WIDTH) % 3};
                            if( (20'b1 << (ENEMY_NUMBER - enemy_counter - 1) & enemy_map) == 0)
                                enemy_counter <= enemy_counter + 1;
                            if(en_ptr < en_size) begin
                                if(en_column == 0) begin
                                    if(~got_vram) begin 
//                                        logic [15:0] player_addr = (p_shift_down + p_ptr) * byte_len - player_coord[7:3];                    

                                        addres_enemy_texture <= (enemy_y + en_ptr[15:1] - 8 * ENEMY_SHIFT * (enemy_counter / ENEMY_NUMBER_WIDTH) ) * byte_len + en_ptr[0] - enemy_x[7:3] - 2 + address_shift - ENEMY_SHIFT * (enemy_counter % ENEMY_NUMBER_WIDTH);                                
                                        got_vram <= 1;
                                    end else begin 
                                        we <= 1;
                                        address_in  <= addres_enemy_texture;
                                        data_in     <= enemy_texture | (en_data >> enemy_x[2:0]);
                                        got_vram    <= 0;
                                        en_column   <= 1;                                
                                    end 
                                end else begin 
                                    if(~got_vram) begin 
                                        addres_enemy_texture <= (enemy_y + en_ptr[15:1] - 8 * ENEMY_SHIFT * (enemy_counter / ENEMY_NUMBER_WIDTH) ) * byte_len + en_ptr[0] - enemy_x[7:3] - 3 + address_shift - ENEMY_SHIFT * (enemy_counter % ENEMY_NUMBER_WIDTH);
                                        got_vram <= 1;
                                    end else begin 
                                        we <= 1;
                                        address_in  <= addres_enemy_texture;
                                        data_in     <= enemy_texture | (en_data << (4'h8 - enemy_x[2:0]));
                                        en_ptr      <= en_ptr + 1;
                                        got_vram    <= 0;
                                        en_column   <= 0;                                                            
                                    end
                                end
                            end else begin 
                                we <= 0;
                                en_ptr <= 0;
                                enemy_counter <= enemy_counter + 1;
                            end
                        end else begin 
                            enemy_counter <= 0;
                            ss <= DRAW_PLAYER;
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
