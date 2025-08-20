`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HBQ TECHNOLOGY
// Engineer: NGO VAN HAT
// 
// Create Date: 05/27/2025 08:55:36 PM
// Design Name: SPI MODULE
// Module Name: Master_SPI_INTF
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


module Master_SPI_INTF #(
    parameter edge_detection_transfer = 1, // tham so nay de lua chon cau tao mosi dua theo slave bat du lieu theo canh
    parameter edge_detection_receive = 1  // tham so nay de lua chon bat du lieu nhan duoc tu slave theo canh len hay canh xuong cua sclk
    )(
    input   clk,    // dua vao xung clock 10mhz
    input   resetn, 
    input   start, 
    input   [7:0] addr, 
    input   [15:0]data_in, 
    output wire [23:0] data_out, 
    output reg done, 
    // input output SPI interface 
    output reg SCLK, 
    output reg CS, 
    output wire MOSI,
    input MISO, 
    output reg SCLN
    );
    
    // tham so cho biet done khi hoan thanh qua trinh dua du lieu len mosi 
    wire done_transmit;
    // tham so thuc hien tao sclk 
    reg [5:0] counter_sclk;
    reg state_sclk;
    
    // tham so tao MOSI theo canh len va canh xuong
    reg s_data_negav; 
    reg s_data_posive;
    // tham so tao xung som pha hon sclk 1 chu ki xung clk 
    //reg SCLN;
    
    // thuc hien tao signal tao xung sclk 
    always@(posedge clk or negedge resetn) begin 
        if(!resetn) begin state_sclk<= 0; counter_sclk <=0; end
        else begin 
                if(start && !state_sclk) begin state_sclk <=1; end
                else if(state_sclk) 
                    begin 
                        counter_sclk <= counter_sclk + 1;
                        if(counter_sclk >= 48)
                            begin
                                 counter_sclk<=0; 
                                 state_sclk <=0; 
                             end
                    end
            end
    end
    
    // thuc hien tao xung sclk dua tren state_sclk
    reg state_LP; // delay 1 chu ky tu thoi diem cs =0 -> dam bao MOSI data chinh xac
    always@(posedge clk or negedge resetn) begin 
        if(!resetn) begin SCLK <=0; state_LP<=0; end
        else begin 
            if(state_sclk) begin
             state_LP<=1; if(state_LP) SCLK <= ~SCLK; 
             end
            else begin SCLK <=0; state_LP<=0; end
        end    
    end
    
    always@(posedge clk or negedge resetn) begin 
        if(!resetn) begin SCLN <=0; end
        else begin 
            if(state_sclk) begin SCLN <= ~SCLN; end
            else begin SCLN <=0; end
        end    
    end
    
    // thuc hien tao tin hieu CS 
    reg prev_done; 
    reg prev_cs; 
    always @(posedge clk or negedge resetn) begin 
        if(!resetn) begin CS <=1; prev_cs <= 1; end
        else begin 
            prev_done <= done_transmit;
            prev_cs <= CS;
            if(start && !state_sclk) begin CS <=0; end 
            else if(!prev_done && done_transmit) begin CS <=1; end
        end
    end
    
    // thuc hien doc du lieu tu miso va mosi dua theo SCLK 
    /* --> thuc hien xuat bit du lieu tiep theo tai canh xuong*/
    reg [23:0]data_transfer; 
    reg [4:0]cnt_bit;
    // thuc hien chot gia tri data_transfer tai thoi diem start tai canh len cua 1 xung clk
    always @(posedge clk or negedge resetn) begin 
        if(!resetn) begin data_transfer <=0; end
        else begin 
            if(start && !state_sclk) begin data_transfer = {addr,data_in}; end 
        end
    end
   // thuc hien tao data cho MOSI cho truong hop slave bat du lieu tai xuong len cua sclk
   reg [4:0]cnt_bit_negav;
   reg done_negav_transmit; 
   reg state_negav;
    always @(negedge SCLN or negedge resetn) begin
        if(!resetn) begin s_data_negav <= 0; cnt_bit_negav<=0; done_negav_transmit<=1; state_negav<=0; end 
        else begin
                done_negav_transmit<=0;
                cnt_bit_negav <= cnt_bit_negav +1; 
                s_data_negav <= data_transfer[23 - cnt_bit_negav];
                if(cnt_bit_negav == 23) begin state_negav<=1; end
                else if(state_negav)begin done_negav_transmit <=1; state_negav<=0; cnt_bit_negav <=0; end
        end
    end
   
   // thuc hien tao data cho MOSI cho truong hop slave bat du lieu tai canh len cua sclk
   reg [4:0]cnt_bit_pos;
   reg done_pos_transmit; 
   reg state_pos;
    always @(posedge SCLN or negedge resetn) begin
        if(!resetn) begin s_data_posive <= 0; cnt_bit_pos<=0; done_pos_transmit<=1; state_pos <=0; end 
        else begin
                done_pos_transmit<=0;
                cnt_bit_pos <= cnt_bit_pos +1; 
                s_data_posive <= data_transfer[23 - cnt_bit_pos];
                if(cnt_bit_pos == 23) begin state_pos<=1; end
                else if(state_pos) begin done_pos_transmit <=1; state_pos <=0; cnt_bit_pos <=0; end
        end
    end
    
   //// thuc hien map output ra ben ngoai ( logic nay co the thay doi bang cach generate tai thoi diem ban dau de tiet kiem logic)
   
   assign MOSI = (edge_detection_transfer)? s_data_posive : s_data_negav;
   
   assign done_transmit = (edge_detection_transfer)? done_pos_transmit: done_negav_transmit;
   
   // thoi diem thong bao done khi dam bao data truyen da duoc dua len va cs = 1 
   always @(posedge clk or negedge resetn) begin 
        if(!resetn) begin done <= 1; end
        else begin
            if(start && !state_sclk) begin done <=0; end 
            else begin 
                if(done_transmit && (!prev_cs && CS)) begin done <=1; end
            end 
        end   
   end
   
   // thuc hien xu ly data receive theo canh len sclk 
   reg [23:0] data_receive_pos; 
   always @(posedge SCLK or negedge resetn) begin 
        if(!resetn) begin data_receive_pos <= 0;  end
        else begin
            data_receive_pos <= {data_receive_pos[22:0],MISO};
        end
   end
   
   // thuc hien xu ly data receive theo canh xuong sclk 
   reg [23:0] data_receive_neg; 
   always @(negedge SCLK or negedge resetn) begin 
        if(!resetn) begin data_receive_neg <= 0;  end
        else begin
            data_receive_neg <= {data_receive_neg[22:0],MISO};
        end
   end
   
   // thuc hien gan du lieu nhan duoc dua theo cau hinh ban dau 
   assign data_out =(edge_detection_receive)? data_receive_pos : data_receive_neg; 
   
       
endmodule

